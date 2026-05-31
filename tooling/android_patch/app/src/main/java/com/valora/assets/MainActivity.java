package com.valora.assets;

import android.Manifest;
import android.app.Activity;
import android.app.AlarmManager;
import android.app.PendingIntent;
import android.appwidget.AppWidgetManager;
import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;
import android.content.Intent;
import android.content.res.ColorStateList;
import android.content.SharedPreferences;
import android.content.ContentValues;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;
import android.content.pm.ShortcutInfo;
import android.content.pm.ShortcutManager;
import android.graphics.Color;
import android.graphics.drawable.GradientDrawable;
import android.graphics.drawable.Icon;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.VibrationEffect;
import android.os.Vibrator;
import android.provider.MediaStore;
import android.provider.Settings;
import android.view.View;
import android.view.ViewGroup;
import android.view.Gravity;
import android.view.Window;
import android.view.WindowInsets;
import android.view.WindowInsetsController;
import android.widget.TextView;
import android.widget.Button;

import androidx.annotation.NonNull;
import androidx.core.content.FileProvider;

import com.google.android.material.datepicker.MaterialDatePicker;
import com.google.android.material.datepicker.CalendarConstraints;
import com.google.android.material.button.MaterialButton;

import com.google.mlkit.vision.text.chinese.ChineseTextRecognizerOptions;

import com.google.mlkit.vision.text.TextRecognizer;

import com.google.mlkit.vision.text.TextRecognition;

import com.google.mlkit.vision.text.Text;

import com.google.mlkit.vision.common.InputImage;

import com.google.mlkit.vision.segmentation.subject.SubjectSegmentation;
import com.google.mlkit.vision.segmentation.subject.SubjectSegmenter;
import com.google.mlkit.vision.segmentation.subject.SubjectSegmenterOptions;

import com.google.mlkit.vision.barcode.common.Barcode;

import com.google.mlkit.vision.barcode.BarcodeScanning;

import com.google.mlkit.vision.barcode.BarcodeScanner;

import java.util.regex.Pattern;

import java.util.regex.Matcher;

import java.io.FileOutputStream;
import java.io.FileInputStream;
import java.io.FileWriter;

import java.io.File;

import android.graphics.Bitmap;
import android.graphics.Rect;
import android.graphics.Paint;
import android.graphics.Canvas;
import android.graphics.BitmapFactory;
import android.graphics.BlurMaskFilter;

import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.charset.StandardCharsets;
import java.nio.FloatBuffer;
import java.util.Arrays;
import java.util.Calendar;
import java.util.HashMap;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.LinkedHashSet;
import java.util.Set;
import java.util.TimeZone;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;
import java.util.zip.ZipInputStream;

import io.flutter.embedding.android.FlutterFragmentActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterFragmentActivity {
    private static final String STORE_CHANNEL = "valora/local_store";
    private static final String NATIVE_CHANNEL = "valora/native";
    private static final String PREFS_NAME = "valora_assets_store";
    private static final String STICKER_PREFS_NAME = "valora_sticker_engine";
    private static final String KEY_JSON = "payload_json";

    private static final int REQ_PICK_IMAGE = 4101;
    private static final int REQ_CAPTURE_PHOTO = 4102;
    private static final int REQ_OPEN_TEXT = 4103;
    private static final int REQ_CREATE_TEXT = 4104;
    private static final int REQ_SCAN_BARCODE = 4105;
    private static final int REQ_OCR_IMAGE = 4106;
    private static final int REQ_CUTOUT_IMAGE = 4107;
    private static final int REQ_CUTOUT_IMAGE_DETAILED = 4108;
    private static final int REQ_OPEN_ARCHIVE = 4109;

    private LocalStoreDb storeDb;
    private MethodChannel nativeChannel;
    private MethodChannel.Result pendingResult;
    private String pendingSaveText;
    private String pendingSaveMimeType;
    private String lastIntentInfo = "";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        // Keep native Material dialogs on the same app theme instead of the launch theme.
        setTheme(R.style.NormalTheme);
        super.onCreate(savedInstanceState);
        lastIntentInfo = intentToJson(getIntent());
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        setIntent(intent);
        lastIntentInfo = intentToJson(intent);
        if (nativeChannel != null) {
            nativeChannel.invokeMethod("incomingShareChanged", lastIntentInfo);
        }
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        storeDb = new LocalStoreDb(this);
        migrateSharedPreferencesToSqlite();

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), STORE_CHANNEL)
                .setMethodCallHandler((call, result) -> {
                    if ("loadJson".equals(call.method)) {
                        result.success(storeDb.loadJson());
                    } else if ("saveJson".equals(call.method)) {
                        String json = call.argument("json");
                        result.success(storeDb.saveJson(json == null ? "" : json));
                    } else if ("clearJson".equals(call.method)) {
                        result.success(storeDb.clearJson());
                    } else {
                        result.notImplemented();
                    }
                });

        nativeChannel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), NATIVE_CHANNEL);
        nativeChannel.setMethodCallHandler((call, result) -> {
            switch (call.method) {
                case "configureSystemUi":
                    configureSystemUi();
                    result.success(true);
                    break;
                case "haptic":
                    triggerHaptic(arg(call.argument("style"), "light"));
                    result.success(true);
                    break;
                case "pickImage":
                    startSingleResult(result, REQ_PICK_IMAGE, buildPickImageIntent());
                    break;
                case "pickNativeDate":
                    showNativeDatePicker(arg(call.argument("initialDate"), ""), arg(call.argument("title"), "选择日期"), result);
                    break;
                case "capturePhoto":
                    startSingleResult(result, REQ_CAPTURE_PHOTO, new Intent(MediaStore.ACTION_IMAGE_CAPTURE));
                    break;
                case "scanBarcodeFromImage":
                    startSingleResult(result, REQ_SCAN_BARCODE, buildPickImageIntent());
                    break;
                case "recognizeReceiptFromImage":
                    startSingleResult(result, REQ_OCR_IMAGE, buildPickImageIntent());
                    break;
                case "cutoutImageFromPicker":
                    startSingleResult(result, REQ_CUTOUT_IMAGE, buildPickImageIntent());
                    break;
                case "cutoutImageFromPickerDetailed":
                    startSingleResult(result, REQ_CUTOUT_IMAGE_DETAILED, buildPickImageIntent());
                    break;
                case "setStickerEngineConfig":
                    setStickerEngineConfig(call.arguments);
                    result.success(true);
                    break;
                case "getStickerEngineConfig":
                    result.success(buildStickerEngineConfigJson(readStickerEngineConfig()));
                    break;
                case "persistImageUri":
                    try {
                        result.success(persistImageUri(arg(call.argument("uri"), "")));
                    } catch (Exception e) {
                        result.error("persist_image_error", e.getMessage(), null);
                    }
                    break;
                case "importTextFile":
                    Intent open = new Intent(Intent.ACTION_OPEN_DOCUMENT);
                    open.addCategory(Intent.CATEGORY_OPENABLE);
                    open.setType(arg(call.argument("mimeType"), "*/*"));
                    startSingleResult(result, REQ_OPEN_TEXT, open);
                    break;
                case "exportTextFile":
                    pendingSaveText = arg(call.argument("text"), "");
                    pendingSaveMimeType = arg(call.argument("mimeType"), "text/plain");
                    Intent create = new Intent(Intent.ACTION_CREATE_DOCUMENT);
                    create.addCategory(Intent.CATEGORY_OPENABLE);
                    create.setType(pendingSaveMimeType);
                    create.putExtra(Intent.EXTRA_TITLE, arg(call.argument("fileName"), "valora_export.txt"));
                    startSingleResult(result, REQ_CREATE_TEXT, create);
                    break;
                case "shareText":
                    shareText(arg(call.argument("title"), "Valora"), arg(call.argument("text"), ""));
                    result.success(true);
                    break;
                case "shareDataArchive":
                    shareDataArchive(call.arguments);
                    result.success(true);
                    break;
                case "importDataArchive":
                    Intent openArchive = new Intent(Intent.ACTION_OPEN_DOCUMENT);
                    openArchive.addCategory(Intent.CATEGORY_OPENABLE);
                    // 不限制 MIME。很多国产文件管理器会把 .zip 标成 application/octet-stream、application/x-zip、甚至 */*，
                    // 之前加 EXTRA_MIME_TYPES 会导致部分设备根本选不到 ZIP。
                    openArchive.setType("*/*");
                    openArchive.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
                    openArchive.addFlags(Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION);
                    startSingleResult(result, REQ_OPEN_ARCHIVE, openArchive);
                    break;
                case "readPrivateTextFile":
                    result.success(readPrivateTextFile(arg(call.argument("path"), "")));
                    break;
                case "readClipboard":
                    result.success(readClipboardText());
                    break;
                case "writeClipboard":
                    writeClipboardText(arg(call.argument("text"), ""));
                    result.success(true);
                    break;
                case "scheduleNotification":
                    scheduleNotification(
                            arg(call.argument("title"), "Valora提醒"),
                            arg(call.argument("text"), "该复盘资产了"),
                            longArg(call.argument("delayMillis"), 60000L)
                    );
                    result.success(true);
                    break;
                case "cancelNotifications":
                    cancelNotification();
                    result.success(true);
                    break;
                case "createShortcuts":
                    result.success(createDynamicShortcuts());
                    break;
                case "updateHomeWidget":
                    updateHomeWidget(call.arguments);
                    result.success(true);
                    break;
                case "getInitialIntentInfo":
                    result.success(lastIntentInfo);
                    break;
                case "requestNotificationPermission":
                    result.success(requestNotificationPermission());
                    break;
                case "openNotificationSettings":
                    openNotificationSettings();
                    result.success(true);
                    break;
                case "openAppSettings":
                    openAppSettings();
                    result.success(true);
                    break;
                default:
                    result.notImplemented();
            }
        });
    }


    private void migrateSharedPreferencesToSqlite() {
        try {
            if (storeDb == null || !storeDb.isEmpty()) return;
            SharedPreferences prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE);
            String legacy = prefs.getString(KEY_JSON, "");
            if (legacy != null && legacy.trim().length() > 0) {
                storeDb.saveJson(legacy);
            }
        } catch (Exception ignored) {
            // Do not block app launch. Empty/corrupted legacy data will fall back to a clean local database.
        }
    }

    private static final class LocalStoreDb extends SQLiteOpenHelper {
        private static final String DB_NAME = "valora_assets_local.db";
        private static final int DB_VERSION = 1;
        private static final String TABLE = "kv_store";
        private static final String KEY = "app_payload_json";

        LocalStoreDb(Context context) {
            super(context.getApplicationContext(), DB_NAME, null, DB_VERSION);
        }

        @Override
        public void onCreate(SQLiteDatabase db) {
            db.execSQL("CREATE TABLE IF NOT EXISTS " + TABLE + " (k TEXT PRIMARY KEY NOT NULL, v TEXT NOT NULL, updated_at INTEGER NOT NULL)");
        }

        @Override
        public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
            onCreate(db);
        }

        synchronized boolean isEmpty() {
            return loadJson().trim().length() == 0;
        }

        synchronized String loadJson() {
            SQLiteDatabase db = getReadableDatabase();
            Cursor cursor = null;
            try {
                cursor = db.query(TABLE, new String[]{"v"}, "k=?", new String[]{KEY}, null, null, null, "1");
                if (cursor.moveToFirst()) {
                    String value = cursor.getString(0);
                    return value == null ? "" : value;
                }
                return "";
            } catch (Exception e) {
                return "";
            } finally {
                if (cursor != null) cursor.close();
            }
        }

        synchronized boolean saveJson(String json) {
            SQLiteDatabase db = getWritableDatabase();
            db.beginTransaction();
            try {
                ContentValues values = new ContentValues();
                values.put("k", KEY);
                values.put("v", json == null ? "" : json);
                values.put("updated_at", System.currentTimeMillis());
                db.insertWithOnConflict(TABLE, null, values, SQLiteDatabase.CONFLICT_REPLACE);
                db.setTransactionSuccessful();
                return true;
            } catch (Exception e) {
                return false;
            } finally {
                db.endTransaction();
            }
        }

        synchronized boolean clearJson() {
            SQLiteDatabase db = getWritableDatabase();
            try {
                db.delete(TABLE, "k=?", new String[]{KEY});
                return true;
            } catch (Exception e) {
                return false;
            }
        }
    }


    private void forceBlueMaterialDatePicker(MaterialDatePicker<?> picker) {
        // Material Components 1.14.0 removed the old show-listener hook on
        // MaterialDatePicker. Keep this method as a no-op so native date picking
        // still compiles and relies on ThemeOverlay_Valora_DatePicker styles.
    }

    private int dp(float value) {
        return Math.round(value * getResources().getDisplayMetrics().density);
    }

    private void applyValoraDatePickerColors(MaterialDatePicker<?> picker, int primary, int primaryDark, int primarySoft) {
        if (picker.getDialog() == null || picker.getDialog().getWindow() == null) return;
        View decor = picker.getDialog().getWindow().getDecorView();
        int headerId = getResources().getIdentifier("mtrl_picker_header", "id", getPackageName());
        View header = headerId == 0 ? null : picker.getDialog().findViewById(headerId);
        if (header != null) {
            GradientDrawable bg = new GradientDrawable(GradientDrawable.Orientation.TOP_BOTTOM, new int[]{Color.WHITE, primarySoft});
            bg.setCornerRadius(0);
            header.setBackground(bg);
        }
        tintDatePickerViewTree(decor, primary, primaryDark, primarySoft);
    }

    private void tintDatePickerViewTree(View view, int primary, int primaryDark, int primarySoft) {
        if (view == null) return;
        String name = "";
        try {
            if (view.getId() != View.NO_ID) name = getResources().getResourceEntryName(view.getId());
        } catch (Exception ignored) { }

        if (view instanceof MaterialButton) {
            MaterialButton button = (MaterialButton) view;
            button.setTextColor(primaryDark);
            button.setRippleColor(ColorStateList.valueOf(Color.argb(52, 124, 198, 242)));
            button.setIconTint(ColorStateList.valueOf(primaryDark));
            button.setBackgroundTintList(ColorStateList.valueOf(Color.TRANSPARENT));
            if (name.contains("confirm") || name.contains("save") || name.contains("positive")) {
                button.setTextColor(primaryDark);
            }
        } else if (view instanceof Button) {
            ((Button) view).setTextColor(primaryDark);
        }

        if (view instanceof TextView) {
            TextView textView = (TextView) view;
            // Keep Android/Material default font metrics; forcing font padding off can make day numbers look vertically misplaced on some ROMs.
            textView.setIncludeFontPadding(true);
            textView.setTextColor(view.isEnabled() ? primaryDark : Color.argb(120, 84, 112, 128));
            CharSequence text = textView.getText();
            boolean looksLikeDayCell = false;
            if (text != null) {
                String s = text.toString().trim();
                looksLikeDayCell = s.matches("\\d{1,2}") || s.matches("\\d{4}");
            }
            if (looksLikeDayCell || name.contains("day") || name.contains("year") || name.contains("calendar")) {
                textView.setGravity(Gravity.CENTER);
                textView.setTextAlignment(View.TEXT_ALIGNMENT_CENTER);
                if (view.isSelected() || view.isActivated() || name.contains("selected")) {
                    GradientDrawable selectedBg = new GradientDrawable();
                    selectedBg.setColor(primary);
                    selectedBg.setCornerRadius(dp(12));
                    textView.setBackground(selectedBg);
                    textView.setTextColor(primaryDark);
                }
            }
        }

        if (view instanceof ViewGroup) {
            ViewGroup group = (ViewGroup) view;
            for (int i = 0; i < group.getChildCount(); i++) {
                tintDatePickerViewTree(group.getChildAt(i), primary, primaryDark, primarySoft);
            }
        }
    }

    private void showNativeDatePicker(String initialDate, String title, MethodChannel.Result result) {
        try {
            final Calendar utc = Calendar.getInstance(TimeZone.getTimeZone("UTC"));
            utc.set(Calendar.HOUR_OF_DAY, 0);
            utc.set(Calendar.MINUTE, 0);
            utc.set(Calendar.SECOND, 0);
            utc.set(Calendar.MILLISECOND, 0);
            Pattern p = Pattern.compile("^(\\d{4})-(\\d{1,2})-(\\d{1,2})$");
            Matcher m = p.matcher(initialDate == null ? "" : initialDate.trim());
            if (m.find()) {
                int y = Integer.parseInt(m.group(1));
                int month = Integer.parseInt(m.group(2));
                int day = Integer.parseInt(m.group(3));
                utc.set(Calendar.YEAR, y);
                utc.set(Calendar.MONTH, Math.max(0, Math.min(11, month - 1)));
                utc.set(Calendar.DAY_OF_MONTH, Math.max(1, Math.min(31, day)));
            }
            Calendar startCal = Calendar.getInstance(TimeZone.getTimeZone("UTC"));
            startCal.clear();
            startCal.set(1970, Calendar.JANUARY, 1);
            Calendar endCal = Calendar.getInstance(TimeZone.getTimeZone("UTC"));
            endCal.clear();
            endCal.set(2100, Calendar.DECEMBER, 31);
            CalendarConstraints constraints = new CalendarConstraints.Builder()
                    .setStart(startCal.getTimeInMillis())
                    .setEnd(endCal.getTimeInMillis())
                    .setOpenAt(utc.getTimeInMillis())
                    .setFirstDayOfWeek(Calendar.MONDAY)
                    .build();

            final boolean[] replied = new boolean[]{false};
            String safeTitle = (title == null || title.trim().isEmpty()) ? "选择日期" : title.trim();
            MaterialDatePicker<Long> picker = MaterialDatePicker.Builder.datePicker()
                    .setTitleText(safeTitle)
                    .setPositiveButtonText("完成")
                    .setNegativeButtonText("取消")
                    .setSelection(utc.getTimeInMillis())
                    .setCalendarConstraints(constraints)
                    .setInputMode(MaterialDatePicker.INPUT_MODE_CALENDAR)
                    .setTheme(R.style.ThemeOverlay_Valora_DatePicker)
                    .build();
            forceBlueMaterialDatePicker(picker);
            picker.addOnPositiveButtonClickListener(selection -> {
                if (replied[0]) return;
                replied[0] = true;
                Calendar selected = Calendar.getInstance(TimeZone.getTimeZone("UTC"));
                selected.setTimeInMillis(selection == null ? utc.getTimeInMillis() : selection);
                result.success(String.format(java.util.Locale.US, "%04d-%02d-%02d",
                        selected.get(Calendar.YEAR),
                        selected.get(Calendar.MONTH) + 1,
                        selected.get(Calendar.DAY_OF_MONTH)));
            });
            picker.addOnNegativeButtonClickListener(v -> {
                if (replied[0]) return;
                replied[0] = true;
                result.success(null);
            });
            picker.addOnCancelListener(v -> {
                if (replied[0]) return;
                replied[0] = true;
                result.success(null);
            });
            picker.addOnDismissListener(v -> {
                if (replied[0]) return;
                replied[0] = true;
                result.success(null);
            });
            picker.show(getSupportFragmentManager(), "Valora_material3_date_picker");
        } catch (Exception e) {
            result.error("date_picker_error", e.getMessage(), null);
        }
    }

    private Intent buildPickImageIntent() {
        // Prefer Android's system Photo Picker on Android 13+ so the cover/sticker workflow
        // opens the native gallery-style picker instead of a generic document browser.
        // The selected image is copied into app-private storage immediately, so persistable
        // URI permission is only needed for the legacy fallback path.
        if (Build.VERSION.SDK_INT >= 33) {
            Intent intent = new Intent("android.provider.action.PICK_IMAGES");
            intent.setType("image/*");
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
            return intent;
        }
        return buildLegacyImageDocumentIntent();
    }

    private Intent buildLegacyImageDocumentIntent() {
        Intent intent = new Intent(Intent.ACTION_OPEN_DOCUMENT);
        intent.addCategory(Intent.CATEGORY_OPENABLE);
        intent.setType("image/*");
        intent.putExtra(Intent.EXTRA_MIME_TYPES, new String[]{"image/jpeg", "image/png", "image/webp", "image/heic", "image/heif"});
        intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
        intent.addFlags(Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION);
        return intent;
    }

    private boolean isImagePickRequest(int requestCode) {
        return requestCode == REQ_PICK_IMAGE
                || requestCode == REQ_SCAN_BARCODE
                || requestCode == REQ_OCR_IMAGE
                || requestCode == REQ_CUTOUT_IMAGE
                || requestCode == REQ_CUTOUT_IMAGE_DETAILED;
    }

    private void tryTakePersistableReadPermission(Intent data, Uri uri) {
        if (data == null || uri == null) return;
        try {
            final int flags = data.getFlags() & Intent.FLAG_GRANT_READ_URI_PERMISSION;
            if (flags != 0) getContentResolver().takePersistableUriPermission(uri, Intent.FLAG_GRANT_READ_URI_PERMISSION);
        } catch (Exception ignored) {}
    }

    private void startSingleResult(MethodChannel.Result result, int requestCode, Intent intent) {
        if (pendingResult != null) {
            result.error("busy", "Another native action is running", null);
            return;
        }
        try {
            pendingResult = result;
            startActivityForResult(intent, requestCode);
        } catch (Exception e) {
            if (isImagePickRequest(requestCode) && Build.VERSION.SDK_INT >= 33) {
                try {
                    startActivityForResult(buildLegacyImageDocumentIntent(), requestCode);
                    return;
                } catch (Exception ignored) {}
            }
            pendingResult = null;
            result.error("native_intent_error", e.getMessage(), null);
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (pendingResult == null) return;
        MethodChannel.Result result = pendingResult;
        pendingResult = null;
        try {
            if (resultCode != Activity.RESULT_OK) {
                result.success(null);
                return;
            }
            if (requestCode == REQ_PICK_IMAGE) {
                Uri uri = data == null ? null : data.getData();
                if (uri != null) tryTakePersistableReadPermission(data, uri);
                result.success(uri == null ? null : persistImageFromUri(uri));
            } else if (requestCode == REQ_CAPTURE_PHOTO) {
                result.success(saveCameraResult(data));
            } else if (requestCode == REQ_SCAN_BARCODE) {
                Uri uri = data == null ? null : data.getData();
                if (uri == null) result.success(null); else scanBarcodeFromUri(uri, result);
                return;
            } else if (requestCode == REQ_OCR_IMAGE) {
                Uri uri = data == null ? null : data.getData();
                if (uri == null) result.success(null); else recognizeReceiptFromUri(uri, result);
                return;
            } else if (requestCode == REQ_CUTOUT_IMAGE) {
                Uri uri = data == null ? null : data.getData();
                if (uri == null) result.success(null); else cutoutImageFromUri(uri, result);
                return;
            } else if (requestCode == REQ_CUTOUT_IMAGE_DETAILED) {
                Uri uri = data == null ? null : data.getData();
                if (uri == null) result.success(null); else cutoutImageFromUriDetailed(uri, result);
                return;
            } else if (requestCode == REQ_OPEN_TEXT) {
                Uri uri = data == null ? null : data.getData();
                result.success(uri == null ? null : readTextFromUri(uri));
            } else if (requestCode == REQ_OPEN_ARCHIVE) {
                Uri uri = data == null ? null : data.getData();
                if (uri == null) {
                    result.success(null);
                } else {
                    try {
                        final int flags = data == null ? 0 : data.getFlags() & (Intent.FLAG_GRANT_READ_URI_PERMISSION | Intent.FLAG_GRANT_WRITE_URI_PERMISSION);
                        getContentResolver().takePersistableUriPermission(uri, flags);
                    } catch (Exception ignored) {}
                    restoreDataArchiveFromUri(uri, result);
                }
                return;
            } else if (requestCode == REQ_CREATE_TEXT) {
                Uri uri = data == null ? null : data.getData();
                if (uri != null) writeTextToUri(uri, pendingSaveText == null ? "" : pendingSaveText);
                result.success(uri == null ? null : uri.toString());
            } else {
                result.success(null);
            }
        } catch (Exception e) {
            result.error("native_result_error", e.getMessage(), null);
        } finally {
            pendingSaveText = null;
            pendingSaveMimeType = null;
        }
    }


    private String persistImageUri(String uriString) throws Exception {
        if (uriString == null || uriString.trim().isEmpty()) return null;
        if (uriString.startsWith("file://")) return uriString;
        return persistImageFromUri(Uri.parse(uriString));
    }

    private String persistImageFromUri(Uri uri) throws Exception {
        if (uri == null) return null;
        InputStream in = getContentResolver().openInputStream(uri);
        if (in == null) return uri.toString();
        String ext = imageExtensionFromMime(getContentResolver().getType(uri));
        File dir = new File(getFilesDir(), "valora_media");
        if (!dir.exists()) dir.mkdirs();
        File file = new File(dir, "asset_" + System.currentTimeMillis() + ext);
        FileOutputStream out = new FileOutputStream(file);
        byte[] buf = new byte[8192];
        int n;
        while ((n = in.read(buf)) >= 0) out.write(buf, 0, n);
        out.flush();
        out.close();
        in.close();
        return "file://" + file.getAbsolutePath();
    }

    private String saveCameraResult(Intent data) throws Exception {
        if (data == null) return null;
        Uri uri = data.getData();
        if (uri != null) return persistImageFromUri(uri);
        Object raw = data.getExtras() == null ? null : data.getExtras().get("data");
        if (raw instanceof Bitmap) {
            File dir = new File(getFilesDir(), "valora_media");
            if (!dir.exists()) dir.mkdirs();
            File file = new File(dir, "camera_" + System.currentTimeMillis() + ".jpg");
            FileOutputStream out = new FileOutputStream(file);
            ((Bitmap) raw).compress(Bitmap.CompressFormat.JPEG, 92, out);
            out.flush();
            out.close();
            return "file://" + file.getAbsolutePath();
        }
        return null;
    }

    private String imageExtensionFromMime(String mime) {
        if (mime == null) return ".jpg";
        if (mime.contains("png")) return ".png";
        if (mime.contains("webp")) return ".webp";
        if (mime.contains("gif")) return ".gif";
        return ".jpg";
    }


    private static final class StickerEngineConfig {
        String mode;
        boolean keepCandidates;
        int decodeMaxSide;
        float[] thresholds;
        int maxCandidates;
    }

    private StickerEngineConfig readStickerEngineConfig() {
        SharedPreferences prefs = getSharedPreferences(STICKER_PREFS_NAME, Context.MODE_PRIVATE);
        String mode = prefs.getString("mode", "balanced");
        boolean keepCandidates = prefs.getBoolean("keepCandidates", false);
        StickerEngineConfig config = new StickerEngineConfig();
        config.mode = mode == null ? "balanced" : mode;
        config.keepCandidates = keepCandidates;
        if ("compact".equals(config.mode)) {
            config.decodeMaxSide = 960;
            config.thresholds = new float[]{0.48f, 0.60f};
            config.maxCandidates = 2;
        } else if ("quality".equals(config.mode)) {
            config.decodeMaxSide = 1600;
            config.thresholds = new float[]{0.32f, 0.46f, 0.60f, 0.72f};
            config.maxCandidates = 4;
        } else if ("hqExperimental".equals(config.mode)) {
            config.decodeMaxSide = 1920;
            config.thresholds = new float[]{0.24f, 0.34f, 0.44f, 0.54f, 0.64f, 0.74f};
            config.maxCandidates = 6;
        } else {
            config.mode = "balanced";
            config.decodeMaxSide = 1280;
            config.thresholds = new float[]{0.38f, 0.46f, 0.58f};
            config.maxCandidates = 3;
        }
        return config;
    }

    @SuppressWarnings("unchecked")
    private void setStickerEngineConfig(Object arguments) {
        Map<String, Object> args = arguments instanceof Map ? (Map<String, Object>) arguments : new HashMap<>();
        String mode = arg(args.get("mode"), "balanced");
        boolean keepCandidates = Boolean.TRUE.equals(args.get("keepCandidates"));
        getSharedPreferences(STICKER_PREFS_NAME, Context.MODE_PRIVATE)
                .edit()
                .putString("mode", mode)
                .putBoolean("keepCandidates", keepCandidates)
                .apply();
    }

    private String buildStickerEngineConfigJson(StickerEngineConfig config) {
        return "{\"mode\":\"" + escape(config.mode) + "\",\"keepCandidates\":" + config.keepCandidates + ",\"decodeMaxSide\":" + config.decodeMaxSide + ",\"maxCandidates\":" + config.maxCandidates + "}";
    }

    private static final class StickerCandidate {
        String uri;
        String label;
        String engine;
        double score;
        int width;
        int height;
    }

    private void cutoutImageFromUri(Uri uri, MethodChannel.Result result) {
        cutoutImageInternal(uri, false, result);
    }

    private void cutoutImageFromUriDetailed(Uri uri, MethodChannel.Result result) {
        cutoutImageInternal(uri, true, result);
    }

    private void cutoutImageInternal(Uri uri, boolean detailed, MethodChannel.Result result) {
        try {
            StickerEngineConfig config = readStickerEngineConfig();
            Bitmap source = decodeScaledBitmap(uri, config.decodeMaxSide);
            if (source == null) {
                String persisted = persistImageFromUri(uri);
                if (detailed) {
                    result.success("{\"selectedUri\":\"" + escape(persisted) + "\",\"candidates\":[]}");
                } else {
                    result.success(persisted);
                }
                return;
            }
            generateStickerCandidates(source, config, candidates -> {
                try {
                    if (candidates == null || candidates.isEmpty()) {
                        Bitmap fallback = createEdgeAwareStickerCutout(source);
                        String path = saveStickerPng(fallback, "cutout_");
                        if (detailed) {
                            StickerCandidate only = new StickerCandidate();
                            only.uri = path;
                            only.label = "兜底";
                            only.engine = "Heuristic";
                            only.score = 0.42;
                            only.width = fallback.getWidth();
                            only.height = fallback.getHeight();
                            List<StickerCandidate> list = new ArrayList<>();
                            list.add(only);
                            result.success(buildStickerJson(path, list));
                        } else {
                            result.success(path);
                        }
                        if (fallback != source) fallback.recycle();
                        return;
                    }
                    Collections.sort(candidates, (a, b) -> Double.compare(b.score, a.score));
                    String best = candidates.get(0).uri;
                    if (detailed) result.success(buildStickerJson(best, candidates)); else result.success(best);
                } catch (Exception e) {
                    result.error("cutout_error", e.getMessage(), null);
                } finally {
                    source.recycle();
                }
            }, error -> {
                try {
                    Bitmap fallback = createEdgeAwareStickerCutout(source);
                    String path = saveStickerPng(fallback, "cutout_");
                    if (detailed) {
                        StickerCandidate only = new StickerCandidate();
                        only.uri = path;
                        only.label = "兜底";
                        only.engine = "Heuristic";
                        only.score = 0.42;
                        only.width = fallback.getWidth();
                        only.height = fallback.getHeight();
                        List<StickerCandidate> list = new ArrayList<>();
                        list.add(only);
                        result.success(buildStickerJson(path, list));
                    } else {
                        result.success(path);
                    }
                    if (fallback != source) fallback.recycle();
                    source.recycle();
                } catch (Exception e) {
                    result.error("cutout_error", e.getMessage() == null ? error.getMessage() : e.getMessage(), null);
                }
            });
        } catch (Exception e) {
            result.error("cutout_error", e.getMessage(), null);
        }
    }

    private interface CandidateSuccess { void accept(List<StickerCandidate> candidates); }
    private interface CandidateFailure { void accept(Exception e); }

    private void generateStickerCandidates(Bitmap source, StickerEngineConfig config, CandidateSuccess success, CandidateFailure failure) {
        final List<StickerCandidate> candidates = new ArrayList<>();
        try {
            // 预留本地 TFLite 模型入口；若未来模型文件存在，可在这里接入。
            candidates.addAll(generateOptionalLocalModelCandidates(source, config));
        } catch (Exception ignored) {}

        try {
            SubjectSegmenterOptions options = new SubjectSegmenterOptions.Builder()
                    .enableForegroundBitmap()
                    .enableForegroundConfidenceMask()
                    .build();
            SubjectSegmenter segmenter = SubjectSegmentation.getClient(options);
            InputImage image = InputImage.fromBitmap(source, 0);
            segmenter.process(image)
                    .addOnSuccessListener(segmentation -> {
                        try {
                            candidates.addAll(generateMlKitCandidates(source, segmentation.getForegroundBitmap(), segmentation.getForegroundConfidenceMask(), config));
                            if (candidates.isEmpty()) {
                                candidates.add(generateHeuristicCandidate(source, "兜底", "Heuristic"));
                            } else {
                                candidates.add(generateHeuristicCandidate(source, "补充兜底", "Heuristic"));
                            }
                            success.accept(deduplicateStickerCandidates(candidates, config.maxCandidates));
                        } catch (Exception e) {
                            failure.accept(e);
                        } finally {
                            segmenter.close();
                        }
                    })
                    .addOnFailureListener(e -> {
                        try {
                            candidates.add(generateHeuristicCandidate(source, "兜底", "Heuristic"));
                            success.accept(deduplicateStickerCandidates(candidates, config.maxCandidates));
                        } catch (Exception inner) {
                            failure.accept(inner);
                        } finally {
                            segmenter.close();
                        }
                    });
        } catch (Throwable mlInitError) {
            try {
                candidates.add(generateHeuristicCandidate(source, "兜底", "Heuristic"));
                success.accept(deduplicateStickerCandidates(candidates, config.maxCandidates));
            } catch (Exception e) {
                failure.accept(e);
            }
        }
    }

    private List<StickerCandidate> generateOptionalLocalModelCandidates(Bitmap source, StickerEngineConfig config) {
        return new ArrayList<>();
    }

    private List<StickerCandidate> generateMlKitCandidates(Bitmap source, Bitmap foregroundBitmap, FloatBuffer confidenceMask, StickerEngineConfig config) throws Exception {
        int w = source.getWidth();
        int h = source.getHeight();
        int[] srcPixels = new int[w * h];
        source.getPixels(srcPixels, 0, w, 0, 0, w, h);
        final List<StickerCandidate> out = new ArrayList<>();
        final float[] thresholds = config.thresholds;
        final String[] labels = new String[]{"保守", "均衡", "激进", "精细"};
        if (confidenceMask != null && confidenceMask.capacity() >= w * h) {
            float[] maskValues = new float[w * h];
            confidenceMask.rewind();
            confidenceMask.get(maskValues);
            for (int i = 0; i < thresholds.length; i++) {
                boolean[] mask = new boolean[w * h];
                for (int p = 0; p < mask.length; p++) mask[p] = maskValues[p] >= thresholds[i];
                StickerCandidate candidate = buildMaskStickerCandidate(source, srcPixels, mask, labels[i], "MLKit " + thresholds[i]);
                if (candidate != null) out.add(candidate);
            }
            return out;
        }
        if (foregroundBitmap != null) {
            Bitmap scaledFg = foregroundBitmap;
            if (foregroundBitmap.getWidth() != w || foregroundBitmap.getHeight() != h) {
                scaledFg = Bitmap.createScaledBitmap(foregroundBitmap, w, h, true);
            }
            int[] fgPixels = new int[w * h];
            scaledFg.getPixels(fgPixels, 0, w, 0, 0, w, h);
            boolean[] mask = new boolean[w * h];
            for (int i = 0; i < mask.length; i++) mask[i] = Color.alpha(fgPixels[i]) > 32;
            StickerCandidate candidate = buildMaskStickerCandidate(source, srcPixels, mask, "均衡", "MLKit alpha");
            if (candidate != null) out.add(candidate);
            if (scaledFg != foregroundBitmap) scaledFg.recycle();
        }
        return out;
    }

    private StickerCandidate generateHeuristicCandidate(Bitmap source, String label, String engine) throws Exception {
        int w = source.getWidth();
        int h = source.getHeight();
        int[] pixels = new int[w * h];
        source.getPixels(pixels, 0, w, 0, 0, w, h);
        BorderStats stats = collectBorderStats(pixels, w, h);
        float[] gradient = sobelGradient(pixels, w, h);
        double threshold = clamp(46.0 + stats.stdDev * 0.85, 50.0, 112.0);
        boolean[] background = floodBackgroundMask(pixels, w, h, stats, gradient, threshold);
        boolean[] foreground = new boolean[w * h];
        for (int i = 0; i < foreground.length; i++) foreground[i] = !background[i] && Color.alpha(pixels[i]) > 8;
        return buildMaskStickerCandidate(source, pixels, foreground, label, engine);
    }

    private StickerCandidate buildMaskStickerCandidate(Bitmap source, int[] srcPixels, boolean[] mask, String label, String engine) throws Exception {
        int w = source.getWidth();
        int h = source.getHeight();
        boolean[] foreground = refineForegroundMask(mask, w, h);
        foreground = keepMeaningfulComponents(foreground, w, h);
        foreground = closeMask(foreground, w, h, 2);
        foreground = featherBoundary(foreground, w, h);
        double ratio = maskRatio(foreground);
        if (ratio < 0.018 || ratio > 0.96) return null;
        Bitmap sticker = renderStickerBitmap(srcPixels, foreground, w, h);
        Bitmap trimmed = trimTransparent(sticker, 4);
        String uri = saveStickerPng(trimmed, "cutout_");
        StickerCandidate candidate = new StickerCandidate();
        candidate.uri = uri;
        candidate.label = label;
        candidate.engine = engine;
        candidate.score = computeMaskScore(foreground, w, h, ratio);
        candidate.width = trimmed.getWidth();
        candidate.height = trimmed.getHeight();
        trimmed.recycle();
        return candidate;
    }

    private double computeMaskScore(boolean[] mask, int w, int h, double ratio) {
        double targetArea = 0.36;
        double areaScore = 1.0 - Math.min(1.0, Math.abs(ratio - targetArea) / targetArea);
        int edgeCount = 0;
        int fgCount = 0;
        int touching = 0;
        int centerCount = 0;
        int cx0 = w / 4, cx1 = (w * 3) / 4, cy0 = h / 4, cy1 = (h * 3) / 4;
        for (int y = 0; y < h; y++) {
            for (int x = 0; x < w; x++) {
                int idx = y * w + x;
                if (!mask[idx]) continue;
                fgCount++;
                if (x == 0 || y == 0 || x == w - 1 || y == h - 1) touching++;
                if (x >= cx0 && x <= cx1 && y >= cy0 && y <= cy1) centerCount++;
                if (hasBackgroundNeighbor(mask, w, h, x, y)) edgeCount++;
            }
        }
        double touchPenalty = fgCount == 0 ? 1.0 : Math.min(1.0, touching / (double)Math.max(1, fgCount) * 20.0);
        double centerScore = fgCount == 0 ? 0 : Math.min(1.0, centerCount / (double)Math.max(1, fgCount) * 2.4);
        double edgeScore = fgCount == 0 ? 0 : 1.0 - Math.min(1.0, edgeCount / (double)Math.max(1, fgCount) * 0.9);
        return clamp(areaScore * 0.42 + centerScore * 0.28 + edgeScore * 0.18 + (1.0 - touchPenalty) * 0.12, 0.0, 0.99);
    }

    private List<StickerCandidate> deduplicateStickerCandidates(List<StickerCandidate> candidates, int maxCandidates) {
        List<StickerCandidate> out = new ArrayList<>();
        for (StickerCandidate item : candidates) {
            if (item == null || item.uri == null || item.uri.trim().isEmpty()) continue;
            boolean duplicate = false;
            for (StickerCandidate kept : out) {
                if (Math.abs(kept.score - item.score) < 0.02 && Math.abs(kept.width - item.width) < 24 && Math.abs(kept.height - item.height) < 24) {
                    duplicate = true;
                    break;
                }
            }
            if (!duplicate) out.add(item);
        }
        Collections.sort(out, (a, b) -> Double.compare(b.score, a.score));
        if (out.size() > maxCandidates) return new ArrayList<>(out.subList(0, maxCandidates));
        return out;
    }

    private String buildStickerJson(String selectedUri, List<StickerCandidate> candidates) {
        StringBuilder sb = new StringBuilder();
        sb.append("{\"selectedUri\":\"").append(escape(selectedUri)).append("\",\"candidates\":[");
        for (int i = 0; i < candidates.size(); i++) {
            StickerCandidate c = candidates.get(i);
            if (i > 0) sb.append(',');
            sb.append("{\"uri\":\"").append(escape(c.uri)).append("\",")
                    .append("\"label\":\"").append(escape(c.label)).append("\",")
                    .append("\"engine\":\"").append(escape(c.engine)).append("\",")
                    .append("\"score\":").append(String.format(java.util.Locale.US, "%.4f", c.score)).append(',')
                    .append("\"width\":").append(c.width).append(',')
                    .append("\"height\":").append(c.height)
                    .append('}');
        }
        sb.append("]}");
        return sb.toString();
    }

    private String saveStickerPng(Bitmap cutout, String prefix) throws Exception {
        File dir = new File(getFilesDir(), "valora_media");
        if (!dir.exists()) dir.mkdirs();
        File file = new File(dir, prefix + System.currentTimeMillis() + ".png");
        FileOutputStream out = new FileOutputStream(file);
        cutout.compress(Bitmap.CompressFormat.PNG, 100, out);
        out.flush();
        out.close();
        return "file://" + file.getAbsolutePath();
    }

    private Bitmap decodeScaledBitmap(Uri uri, int maxSide) throws Exception {
        InputStream boundsStream = getContentResolver().openInputStream(uri);
        if (boundsStream == null) return null;
        BitmapFactory.Options bounds = new BitmapFactory.Options();
        bounds.inJustDecodeBounds = true;
        BitmapFactory.decodeStream(boundsStream, null, bounds);
        boundsStream.close();
        int largest = Math.max(bounds.outWidth, bounds.outHeight);
        int sample = 1;
        while (largest / sample > maxSide) sample *= 2;
        BitmapFactory.Options opts = new BitmapFactory.Options();
        opts.inPreferredConfig = Bitmap.Config.ARGB_8888;
        opts.inSampleSize = Math.max(1, sample);
        InputStream in = getContentResolver().openInputStream(uri);
        Bitmap decoded = BitmapFactory.decodeStream(in, null, opts);
        if (in != null) in.close();
        return decoded;
    }

    private Bitmap createStickerFromMlKitResult(Bitmap source, Bitmap foregroundBitmap, FloatBuffer confidenceMask) {
        int w = source.getWidth();
        int h = source.getHeight();
        int[] srcPixels = new int[w * h];
        source.getPixels(srcPixels, 0, w, 0, 0, w, h);
        boolean[] foreground = new boolean[w * h];

        if (confidenceMask != null && confidenceMask.capacity() >= w * h) {
            confidenceMask.rewind();
            for (int i = 0; i < foreground.length; i++) {
                float v = confidenceMask.get();
                foreground[i] = v >= 0.46f;
            }
        } else if (foregroundBitmap != null) {
            Bitmap scaledFg = foregroundBitmap;
            if (foregroundBitmap.getWidth() != w || foregroundBitmap.getHeight() != h) {
                scaledFg = Bitmap.createScaledBitmap(foregroundBitmap, w, h, true);
            }
            int[] fgPixels = new int[w * h];
            scaledFg.getPixels(fgPixels, 0, w, 0, 0, w, h);
            for (int i = 0; i < foreground.length; i++) foreground[i] = Color.alpha(fgPixels[i]) > 32;
            if (scaledFg != foregroundBitmap) scaledFg.recycle();
        } else {
            return createEdgeAwareStickerCutout(source);
        }

        foreground = refineForegroundMask(foreground, w, h);
        foreground = keepMeaningfulComponents(foreground, w, h);
        foreground = closeMask(foreground, w, h, 2);
        foreground = featherBoundary(foreground, w, h);
        double ratio = maskRatio(foreground);
        if (ratio < 0.018 || ratio > 0.96) return createEdgeAwareStickerCutout(source);
        Bitmap sticker = renderStickerBitmap(srcPixels, foreground, w, h);
        return trimTransparent(sticker, 4);
    }

    private Bitmap createEdgeAwareStickerCutout(Bitmap src) {
        int w = src.getWidth();
        int h = src.getHeight();
        int[] pixels = new int[w * h];
        src.getPixels(pixels, 0, w, 0, 0, w, h);

        BorderStats stats = collectBorderStats(pixels, w, h);
        float[] gradient = sobelGradient(pixels, w, h);
        double threshold = clamp(46.0 + stats.stdDev * 0.85, 50.0, 112.0);

        boolean[] background = floodBackgroundMask(pixels, w, h, stats, gradient, threshold);
        double fgRatio = foregroundRatio(background);
        if (fgRatio > 0.84) {
            background = floodBackgroundMask(pixels, w, h, stats, gradient, threshold * 1.28);
        } else if (fgRatio < 0.035) {
            background = floodBackgroundMask(pixels, w, h, stats, gradient, threshold * 0.82);
        }

        boolean[] foreground = new boolean[w * h];
        for (int i = 0; i < foreground.length; i++) {
            foreground[i] = !background[i] && Color.alpha(pixels[i]) > 8;
        }
        foreground = refineForegroundMask(foreground, w, h);
        foreground = keepMeaningfulComponents(foreground, w, h);
        foreground = closeMask(foreground, w, h, 1);
        double refinedRatio = maskRatio(foreground);
        if (refinedRatio < 0.018 || refinedRatio > 0.96) {
            foreground = fallbackForegroundMask(pixels, w, h, stats, threshold);
        }

        Bitmap sticker = renderStickerBitmap(pixels, foreground, w, h);
        return trimTransparent(sticker, 3);
    }

    private static final class BorderStats {
        int r;
        int g;
        int b;
        int luma;
        double stdDev;
    }

    private BorderStats collectBorderStats(int[] pixels, int w, int h) {
        int step = Math.max(1, Math.min(w, h) / 160);
        long r = 0, g = 0, b = 0, lum = 0, count = 0;
        for (int x = 0; x < w; x += step) {
            int c1 = pixels[x];
            int c2 = pixels[(h - 1) * w + x];
            r += Color.red(c1) + Color.red(c2);
            g += Color.green(c1) + Color.green(c2);
            b += Color.blue(c1) + Color.blue(c2);
            lum += luma(c1) + luma(c2);
            count += 2;
        }
        for (int y = 0; y < h; y += step) {
            int c1 = pixels[y * w];
            int c2 = pixels[y * w + (w - 1)];
            r += Color.red(c1) + Color.red(c2);
            g += Color.green(c1) + Color.green(c2);
            b += Color.blue(c1) + Color.blue(c2);
            lum += luma(c1) + luma(c2);
            count += 2;
        }
        BorderStats stats = new BorderStats();
        if (count <= 0) {
            stats.r = 255; stats.g = 255; stats.b = 255; stats.luma = 255; stats.stdDev = 18.0;
            return stats;
        }
        stats.r = (int)(r / count);
        stats.g = (int)(g / count);
        stats.b = (int)(b / count);
        stats.luma = (int)(lum / count);

        double variance = 0.0;
        long varianceCount = 0;
        for (int x = 0; x < w; x += step) {
            variance += sq(colorDistance(pixels[x], stats));
            variance += sq(colorDistance(pixels[(h - 1) * w + x], stats));
            varianceCount += 2;
        }
        for (int y = 0; y < h; y += step) {
            variance += sq(colorDistance(pixels[y * w], stats));
            variance += sq(colorDistance(pixels[y * w + (w - 1)], stats));
            varianceCount += 2;
        }
        stats.stdDev = Math.sqrt(variance / Math.max(1, varianceCount));
        return stats;
    }

    private float[] sobelGradient(int[] pixels, int w, int h) {
        int[] gray = new int[w * h];
        for (int i = 0; i < pixels.length; i++) gray[i] = luma(pixels[i]);
        float[] grad = new float[w * h];
        for (int y = 1; y < h - 1; y++) {
            int row = y * w;
            for (int x = 1; x < w - 1; x++) {
                int idx = row + x;
                int gx = -gray[idx - w - 1] + gray[idx - w + 1]
                        - 2 * gray[idx - 1] + 2 * gray[idx + 1]
                        - gray[idx + w - 1] + gray[idx + w + 1];
                int gy = -gray[idx - w - 1] - 2 * gray[idx - w] - gray[idx - w + 1]
                        + gray[idx + w - 1] + 2 * gray[idx + w] + gray[idx + w + 1];
                grad[idx] = (float)Math.min(255.0, Math.sqrt(gx * gx + gy * gy) / 4.0);
            }
        }
        return grad;
    }

    private boolean[] floodBackgroundMask(int[] pixels, int w, int h, BorderStats stats, float[] gradient, double threshold) {
        int n = w * h;
        boolean[] bg = new boolean[n];
        int[] queue = new int[n];
        int head = 0;
        int tail = 0;
        for (int x = 0; x < w; x++) {
            tail = enqueueIfBackground(0 * w + x, pixels, bg, queue, tail, stats, gradient, threshold * 1.18);
            tail = enqueueIfBackground((h - 1) * w + x, pixels, bg, queue, tail, stats, gradient, threshold * 1.18);
        }
        for (int y = 0; y < h; y++) {
            tail = enqueueIfBackground(y * w, pixels, bg, queue, tail, stats, gradient, threshold * 1.18);
            tail = enqueueIfBackground(y * w + (w - 1), pixels, bg, queue, tail, stats, gradient, threshold * 1.18);
        }
        while (head < tail) {
            int idx = queue[head++];
            int x = idx % w;
            int y = idx / w;
            if (x > 0) tail = enqueueIfBackground(idx - 1, pixels, bg, queue, tail, stats, gradient, threshold);
            if (x < w - 1) tail = enqueueIfBackground(idx + 1, pixels, bg, queue, tail, stats, gradient, threshold);
            if (y > 0) tail = enqueueIfBackground(idx - w, pixels, bg, queue, tail, stats, gradient, threshold);
            if (y < h - 1) tail = enqueueIfBackground(idx + w, pixels, bg, queue, tail, stats, gradient, threshold);
        }
        return bg;
    }

    private int enqueueIfBackground(int idx, int[] pixels, boolean[] bg, int[] queue, int tail, BorderStats stats, float[] gradient, double threshold) {
        if (idx < 0 || idx >= pixels.length || bg[idx]) return tail;
        if (isEdgeAwareBackground(pixels[idx], stats, gradient[idx], threshold)) {
            bg[idx] = true;
            if (tail < queue.length) queue[tail++] = idx;
        }
        return tail;
    }

    private boolean isEdgeAwareBackground(int color, BorderStats stats, float gradient, double threshold) {
        if (Color.alpha(color) < 12) return true;
        double colorDist = colorDistance(color, stats);
        int lum = luma(color);
        double lumaDist = Math.abs(lum - stats.luma) * 0.62;
        double edgePenalty = Math.max(0.0, gradient - 18.0) * 0.55;
        double score = colorDist * 0.76 + lumaDist + edgePenalty;
        return score < threshold;
    }


    private boolean[] fallbackForegroundMask(int[] pixels, int w, int h, BorderStats stats, double threshold) {
        boolean[] fg = new boolean[w * h];
        double keepThreshold = Math.max(62.0, threshold * 1.10);
        for (int i = 0; i < pixels.length; i++) {
            int c = pixels[i];
            double dist = colorDistance(c, stats) + Math.abs(luma(c) - stats.luma) * 0.35;
            fg[i] = Color.alpha(c) > 8 && dist > keepThreshold;
        }
        fg = refineForegroundMask(fg, w, h);
        fg = keepMeaningfulComponents(fg, w, h);
        return closeMask(fg, w, h, 1);
    }

    private double maskRatio(boolean[] mask) {
        int count = 0;
        for (boolean v : mask) if (v) count++;
        return count / (double)Math.max(1, mask.length);
    }

    private boolean[] refineForegroundMask(boolean[] fg, int w, int h) {
        boolean[] current = Arrays.copyOf(fg, fg.length);
        for (int pass = 0; pass < 2; pass++) {
            boolean[] next = Arrays.copyOf(current, current.length);
            for (int y = 1; y < h - 1; y++) {
                for (int x = 1; x < w - 1; x++) {
                    int idx = y * w + x;
                    int count = foregroundNeighborCount(current, w, x, y);
                    if (current[idx] && count <= 1) next[idx] = false;
                    if (!current[idx] && count >= 7) next[idx] = true;
                }
            }
            current = next;
        }
        return current;
    }


    private boolean[] keepMeaningfulComponents(boolean[] fg, int w, int h) {
        int n = w * h;
        int[] labels = new int[n];
        int[] queue = new int[n];
        int label = 0;
        int bestLabel = 0;
        double bestScore = -1;
        int centerX = w / 2;
        int centerY = h / 2;
        int minArea = Math.max(18, n / 1800);
        int[] areas = new int[Math.max(64, n / 64)];

        for (int i = 0; i < n; i++) {
            if (!fg[i] || labels[i] != 0) continue;
            label++;
            if (label >= areas.length) areas = Arrays.copyOf(areas, areas.length * 2);
            int head = 0, tail = 0;
            queue[tail++] = i;
            labels[i] = label;
            int area = 0;
            long sx = 0, sy = 0;
            while (head < tail) {
                int idx = queue[head++];
                area++;
                int x = idx % w;
                int y = idx / w;
                sx += x;
                sy += y;
                if (x > 0) tail = enqueueComponent(idx - 1, label, fg, labels, queue, tail);
                if (x < w - 1) tail = enqueueComponent(idx + 1, label, fg, labels, queue, tail);
                if (y > 0) tail = enqueueComponent(idx - w, label, fg, labels, queue, tail);
                if (y < h - 1) tail = enqueueComponent(idx + w, label, fg, labels, queue, tail);
            }
            areas[label] = area;
            double cx = sx / (double)Math.max(1, area);
            double cy = sy / (double)Math.max(1, area);
            double centerDistance = Math.hypot((cx - centerX) / Math.max(1.0, w), (cy - centerY) / Math.max(1.0, h));
            double score = area * (1.0 - Math.min(0.82, centerDistance));
            if (area >= minArea && score > bestScore) {
                bestScore = score;
                bestLabel = label;
            }
        }

        if (bestLabel == 0) return fg;
        boolean[] out = new boolean[n];
        int bestArea = areas[bestLabel];
        for (int i = 0; i < n; i++) {
            int lab = labels[i];
            if (lab == bestLabel || (lab > 0 && areas[lab] >= bestArea * 0.16 && areas[lab] >= minArea * 3)) {
                out[i] = true;
            }
        }
        return out;
    }

    private int enqueueComponent(int idx, int label, boolean[] fg, int[] labels, int[] queue, int tail) {
        if (idx < 0 || idx >= fg.length || !fg[idx] || labels[idx] != 0) return tail;
        labels[idx] = label;
        if (tail < queue.length) queue[tail++] = idx;
        return tail;
    }

    private boolean[] closeMask(boolean[] fg, int w, int h, int radius) {
        boolean[] dilated = Arrays.copyOf(fg, fg.length);
        for (int y = 0; y < h; y++) {
            for (int x = 0; x < w; x++) {
                int idx = y * w + x;
                if (fg[idx]) continue;
                boolean near = false;
                for (int yy = Math.max(0, y - radius); yy <= Math.min(h - 1, y + radius) && !near; yy++) {
                    for (int xx = Math.max(0, x - radius); xx <= Math.min(w - 1, x + radius); xx++) {
                        if (fg[yy * w + xx]) { near = true; break; }
                    }
                }
                if (near) dilated[idx] = true;
            }
        }
        boolean[] eroded = Arrays.copyOf(dilated, dilated.length);
        for (int y = 0; y < h; y++) {
            for (int x = 0; x < w; x++) {
                int idx = y * w + x;
                if (!dilated[idx]) continue;
                boolean all = true;
                for (int yy = Math.max(0, y - radius); yy <= Math.min(h - 1, y + radius) && all; yy++) {
                    for (int xx = Math.max(0, x - radius); xx <= Math.min(w - 1, x + radius); xx++) {
                        if (!dilated[yy * w + xx]) { all = false; break; }
                    }
                }
                eroded[idx] = all;
            }
        }
        return eroded;
    }

    private boolean[] featherBoundary(boolean[] fg, int w, int h) {
        // 这里仍返回布尔 mask，真正的半透明边缘在 renderStickerBitmap 中根据邻域动态减淡。
        // 单独保留这个函数是为了后续如果要接入 TFLite alpha matting，可以只替换这里。
        return fg;
    }

    private int foregroundNeighborCount(boolean[] fg, int w, int x, int y) {
        int count = 0;
        int base = y * w + x;
        if (fg[base - w - 1]) count++;
        if (fg[base - w]) count++;
        if (fg[base - w + 1]) count++;
        if (fg[base - 1]) count++;
        if (fg[base + 1]) count++;
        if (fg[base + w - 1]) count++;
        if (fg[base + w]) count++;
        if (fg[base + w + 1]) count++;
        return count;
    }

    private Bitmap renderStickerBitmap(int[] pixels, boolean[] fg, int w, int h) {
        int stroke = Math.max(10, Math.min(24, Math.min(w, h) / 54));
        int padding = stroke * 3;
        int ow = w + padding * 2;
        int oh = h + padding * 2;

        Bitmap foreground = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888);
        Bitmap maskWhite = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888);
        Bitmap maskBlue = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888);
        int[] fgPixels = new int[w * h];
        int[] whitePixels = new int[w * h];
        int[] bluePixels = new int[w * h];
        for (int y = 0; y < h; y++) {
            for (int x = 0; x < w; x++) {
                int idx = y * w + x;
                if (!fg[idx]) continue;
                int a = hasBackgroundNeighbor(fg, w, h, x, y) ? 236 : 255;
                int c = pixels[idx];
                fgPixels[idx] = Color.argb(Math.min(a, Color.alpha(c)), Color.red(c), Color.green(c), Color.blue(c));
                whitePixels[idx] = Color.argb(255, 255, 255, 255);
                bluePixels[idx] = Color.argb(86, 124, 198, 242);
            }
        }
        foreground.setPixels(fgPixels, 0, w, 0, 0, w, h);
        maskWhite.setPixels(whitePixels, 0, w, 0, 0, w, h);
        maskBlue.setPixels(bluePixels, 0, w, 0, 0, w, h);

        Bitmap out = Bitmap.createBitmap(ow, oh, Bitmap.Config.ARGB_8888);
        Canvas canvas = new Canvas(out);

        Paint shadowPaint = new Paint(Paint.ANTI_ALIAS_FLAG | Paint.FILTER_BITMAP_FLAG);
        shadowPaint.setMaskFilter(new BlurMaskFilter(stroke * 1.35f, BlurMaskFilter.Blur.NORMAL));
        canvas.drawBitmap(maskBlue, padding, padding + stroke / 3f, shadowPaint);

        Paint outlinePaint = new Paint(Paint.ANTI_ALIAS_FLAG | Paint.FILTER_BITMAP_FLAG);
        for (int dy = -stroke; dy <= stroke; dy += Math.max(1, stroke / 5)) {
            for (int dx = -stroke; dx <= stroke; dx += Math.max(1, stroke / 5)) {
                if (dx * dx + dy * dy <= stroke * stroke) {
                    canvas.drawBitmap(maskWhite, padding + dx, padding + dy, outlinePaint);
                }
            }
        }

        Paint foregroundPaint = new Paint(Paint.ANTI_ALIAS_FLAG | Paint.FILTER_BITMAP_FLAG);
        canvas.drawBitmap(foreground, padding, padding, foregroundPaint);
        foreground.recycle();
        maskWhite.recycle();
        maskBlue.recycle();
        return out;
    }

    private boolean hasBackgroundNeighbor(boolean[] fg, int w, int h, int x, int y) {
        for (int yy = Math.max(0, y - 1); yy <= Math.min(h - 1, y + 1); yy++) {
            for (int xx = Math.max(0, x - 1); xx <= Math.min(w - 1, x + 1); xx++) {
                if (!fg[yy * w + xx]) return true;
            }
        }
        return false;
    }

    private double foregroundRatio(boolean[] background) {
        int fg = 0;
        for (boolean isBg : background) if (!isBg) fg++;
        return fg / (double)Math.max(1, background.length);
    }

    private double colorDistance(int color, BorderStats stats) {
        int dr = Color.red(color) - stats.r;
        int dg = Color.green(color) - stats.g;
        int db = Color.blue(color) - stats.b;
        return Math.sqrt(dr * dr * 0.85 + dg * dg * 1.05 + db * db * 1.10);
    }

    private static int luma(int color) {
        return (int)(Color.red(color) * 0.299 + Color.green(color) * 0.587 + Color.blue(color) * 0.114);
    }

    private static double sq(double value) {
        return value * value;
    }

    private static double clamp(double value, double min, double max) {
        return Math.max(min, Math.min(max, value));
    }

    private Bitmap trimTransparent(Bitmap src, int padding) {
        int w = src.getWidth();
        int h = src.getHeight();
        int left = w, top = h, right = 0, bottom = 0;
        int[] pixels = new int[w * h];
        src.getPixels(pixels, 0, w, 0, 0, w, h);
        for (int y = 0; y < h; y++) {
            for (int x = 0; x < w; x++) {
                if (Color.alpha(pixels[y * w + x]) > 8) {
                    if (x < left) left = x;
                    if (x > right) right = x;
                    if (y < top) top = y;
                    if (y > bottom) bottom = y;
                }
            }
        }
        if (right <= left || bottom <= top) return src;
        left = Math.max(0, left - padding);
        top = Math.max(0, top - padding);
        right = Math.min(w - 1, right + padding);
        bottom = Math.min(h - 1, bottom + padding);
        Bitmap cropped = Bitmap.createBitmap(src, left, top, right - left + 1, bottom - top + 1);
        src.recycle();
        return cropped;
    }

    private void scanBarcodeFromUri(Uri uri, MethodChannel.Result result) {
        try {
            InputImage image = InputImage.fromFilePath(this, uri);
            BarcodeScanner scanner = BarcodeScanning.getClient();
            scanner.process(image)
                    .addOnSuccessListener(barcodes -> {
                        if (barcodes == null || barcodes.isEmpty()) {
                            result.success("{\"found\":false,\"rawValue\":\"\",\"displayValue\":\"\",\"format\":\"\"}");
                            return;
                        }
                        Barcode b = barcodes.get(0);
                        String raw = b.getRawValue() == null ? "" : b.getRawValue();
                        String display = b.getDisplayValue() == null ? raw : b.getDisplayValue();
                        result.success("{"
                                + "\"found\":true,"
                                + "\"rawValue\":\"" + escape(raw) + "\","
                                + "\"displayValue\":\"" + escape(display) + "\","
                                + "\"format\":\"" + escape(String.valueOf(b.getFormat())) + "\""
                                + "}");
                    })
                    .addOnFailureListener(e -> result.error("barcode_scan_error", e.getMessage(), null));
        } catch (Exception e) {
            result.error("barcode_scan_error", e.getMessage(), null);
        }
    }

    private void recognizeReceiptFromUri(Uri uri, MethodChannel.Result result) {
        try {
            InputImage image = InputImage.fromFilePath(this, uri);
            TextRecognizer recognizer = TextRecognition.getClient(new ChineseTextRecognizerOptions.Builder().build());
            recognizer.process(image)
                    .addOnSuccessListener(text -> {
                        String fullText = text == null ? "" : text.getText();
                        String price = guessReceiptPrice(fullText);
                        String date = guessReceiptDate(fullText);
                        String title = guessReceiptTitle(fullText);
                        result.success("{"
                                + "\"found\":" + (!fullText.trim().isEmpty()) + ","
                                + "\"fullText\":\"" + escape(fullText) + "\","
                                + "\"priceCandidate\":\"" + escape(price) + "\","
                                + "\"dateCandidate\":\"" + escape(date) + "\","
                                + "\"nameCandidate\":\"" + escape(title) + "\""
                                + "}");
                    })
                    .addOnFailureListener(e -> result.error("ocr_error", e.getMessage(), null));
        } catch (Exception e) {
            result.error("ocr_error", e.getMessage(), null);
        }
    }

    private String guessReceiptPrice(String text) {
        if (text == null) return "";
        Pattern p = Pattern.compile("(?i)(合计|总计|实付|应付|金额|TOTAL|AMOUNT)[^0-9]{0,12}([0-9]+(?:\\.[0-9]{1,2})?)");
        Matcher m = p.matcher(text);
        String best = "";
        while (m.find()) best = m.group(2);
        if (!best.isEmpty()) return best;
        Pattern number = Pattern.compile("([0-9]+(?:\\.[0-9]{1,2})?)");
        Matcher n = number.matcher(text);
        double max = -1;
        while (n.find()) {
            try {
                double v = Double.parseDouble(n.group(1));
                if (v > max && v < 10000000) max = v;
            } catch (Exception ignored) {}
        }
        return max > 0 ? String.format(java.util.Locale.US, "%.2f", max) : "";
    }

    private String guessReceiptDate(String text) {
        if (text == null) return "";
        Pattern p = Pattern.compile("(20[0-9]{2})[年\\-/\\.](0?[1-9]|1[0-2])[月\\-/\\.](0?[1-9]|[12][0-9]|3[01])");
        Matcher m = p.matcher(text);
        if (m.find()) {
            int y = Integer.parseInt(m.group(1));
            int mo = Integer.parseInt(m.group(2));
            int d = Integer.parseInt(m.group(3));
            return String.format(java.util.Locale.US, "%04d-%02d-%02d", y, mo, d);
        }
        return "";
    }

    private String guessReceiptTitle(String text) {
        if (text == null) return "";
        String[] lines = text.split("\\n");
        for (String line : lines) {
            String trimmed = line.trim();
            if (trimmed.length() >= 2 && trimmed.length() <= 28 && !trimmed.matches(".*[0-9]{4,}.*")) return trimmed;
        }
        return "";
    }

    private void configureSystemUi() {
        Window window = getWindow();
        if (Build.VERSION.SDK_INT >= 21) {
            window.setStatusBarColor(Color.TRANSPARENT);
            window.setNavigationBarColor(Color.TRANSPARENT);
        }
        if (Build.VERSION.SDK_INT >= 23) {
            int flags = View.SYSTEM_UI_FLAG_LAYOUT_STABLE | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN | View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR;
            if (Build.VERSION.SDK_INT >= 26) flags |= View.SYSTEM_UI_FLAG_LIGHT_NAVIGATION_BAR;
            window.getDecorView().setSystemUiVisibility(flags);
        }
    }

    private void triggerHaptic(String style) {
        try {
            Vibrator vibrator = (Vibrator) getSystemService(Context.VIBRATOR_SERVICE);
            if (vibrator == null || !vibrator.hasVibrator()) return;
            long duration = "success".equals(style) ? 36 : "warning".equals(style) ? 52 : "medium".equals(style) ? 28 : 14;
            int amplitude = "success".equals(style) ? 170 : "warning".equals(style) ? 220 : "medium".equals(style) ? 145 : 90;
            if (Build.VERSION.SDK_INT >= 26) {
                vibrator.vibrate(VibrationEffect.createOneShot(duration, amplitude));
            } else {
                vibrator.vibrate(duration);
            }
        } catch (Exception ignored) {}
    }

    private String readTextFromUri(Uri uri) throws Exception {
        InputStream in = getContentResolver().openInputStream(uri);
        if (in == null) return "";
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        byte[] buf = new byte[8192];
        int n;
        while ((n = in.read(buf)) >= 0) out.write(buf, 0, n);
        in.close();
        return new String(out.toByteArray(), StandardCharsets.UTF_8);
    }

    private void writeTextToUri(Uri uri, String text) throws Exception {
        OutputStream out = getContentResolver().openOutputStream(uri);
        if (out == null) return;
        out.write(text.getBytes(StandardCharsets.UTF_8));
        out.flush();
        out.close();
    }

    @SuppressWarnings("unchecked")
    private void shareDataArchive(Object arguments) {
        Map<String, Object> args = arguments instanceof Map ? (Map<String, Object>) arguments : new HashMap<>();
        String title = arg(args.get("title"), "Valora完整资料包");
        String json = arg(args.get("json"), "{}");
        String csv = arg(args.get("csv"), "");
        String markdown = arg(args.get("markdown"), "");
        String fileName = sanitizeArchiveFileName(arg(args.get("fileName"), "valora_complete_backup.zip"));
        Object rawPaths = args.get("mediaPaths");
        List<String> mediaPaths = new ArrayList<>();
        if (rawPaths instanceof List) {
            for (Object item : (List<?>) rawPaths) {
                if (item != null && item.toString().trim().length() > 0) mediaPaths.add(item.toString());
            }
        }
        try {
            if (storeDb != null && json.trim().length() > 0) storeDb.saveJson(json);
            File shareDir = new File(getCacheDir(), "share");
            if (!shareDir.exists()) shareDir.mkdirs();
            File zip = new File(shareDir, fileName.endsWith(".zip") ? fileName : fileName + ".zip");
            ZipOutputStream zos = new ZipOutputStream(new FileOutputStream(zip));
            addTextEntry(zos, "backup/valora_backup.json", json);
            addTextEntry(zos, "backup/valora_assets.csv", csv);
            addTextEntry(zos, "backup/valora_report.md", markdown);
            addTextEntry(zos, "README.txt", "Valora完整资料包\n\n包含：\n- backup/valora_backup.json：可恢复的结构化数据\n- backup/valora_assets.csv：资产表格\n- backup/valora_report.md：资产报告\n- backup/media_manifest.tsv：媒体原路径与 ZIP 路径映射，用于跨设备恢复图片\n- sqlite/：应用当前 SQLite 数据库副本\n- media/：本地封面、贴纸、手动勾勒图片等媒体文件\n\n说明：恢复时优先使用 JSON + media 重建当前 SQLite，不会直接覆盖运行中的数据库文件。\n");
            addSqliteFiles(zos);
            String mediaManifest = addMediaFiles(zos, mediaPaths);
            addTextEntry(zos, "backup/media_manifest.tsv", mediaManifest);
            zos.close();
            Uri uri = FileProvider.getUriForFile(this, getPackageName() + ".fileprovider", zip);
            Intent send = new Intent(Intent.ACTION_SEND);
            send.setType("application/zip");
            send.putExtra(Intent.EXTRA_SUBJECT, title);
            send.putExtra(Intent.EXTRA_STREAM, uri);
            send.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
            startActivity(Intent.createChooser(send, title));
        } catch (Exception e) {
            shareText(title, "完整资料包生成失败：" + e.getMessage() + "\n\n" + markdown);
        }
    }

    private String sanitizeArchiveFileName(String name) {
        String clean = name == null ? "valora_complete_backup.zip" : name.replaceAll("[^a-zA-Z0-9._-]", "_");
        if (clean.trim().length() == 0) clean = "valora_complete_backup.zip";
        return clean;
    }

    private void addTextEntry(ZipOutputStream zos, String name, String text) throws Exception {
        ZipEntry entry = new ZipEntry(name);
        zos.putNextEntry(entry);
        byte[] bytes = (text == null ? "" : text).getBytes(StandardCharsets.UTF_8);
        zos.write(bytes);
        zos.closeEntry();
    }

    private void addFileEntry(ZipOutputStream zos, File file, String entryName) throws Exception {
        if (file == null || !file.exists() || !file.isFile()) return;
        zos.putNextEntry(new ZipEntry(entryName));
        FileInputStream in = new FileInputStream(file);
        byte[] buf = new byte[8192];
        int n;
        while ((n = in.read(buf)) >= 0) zos.write(buf, 0, n);
        in.close();
        zos.closeEntry();
    }

    private void addSqliteFiles(ZipOutputStream zos) throws Exception {
        String[] names = new String[]{"valora_assets_local.db", "valora_assets_local.db-wal", "valora_assets_local.db-shm"};
        for (String name : names) {
            File db = getDatabasePath(name);
            if (db != null && db.exists()) addFileEntry(zos, db, "sqlite/" + name);
        }
    }

    private String addMediaFiles(ZipOutputStream zos, List<String> mediaPaths) throws Exception {
        Set<String> seen = new LinkedHashSet<>();
        StringBuilder manifest = new StringBuilder();
        manifest.append("entry\toriginalPath\toriginalUri\toriginalName\n");
        int index = 1;
        for (String raw : mediaPaths) {
            String originalUri = raw == null ? "" : raw.trim();
            String path = originalUri;
            if (path.startsWith("file://")) path = Uri.parse(path).getPath();
            if (path.length() == 0 || seen.contains(path)) continue;
            seen.add(path);
            File file = new File(path);
            if (!file.exists() || !file.isFile()) continue;
            String originalName = file.getName();
            String safeName = originalName.replaceAll("[^a-zA-Z0-9._-]", "_");
            if (safeName.length() == 0) safeName = "media_" + index;
            String entryName = "media/" + String.format(java.util.Locale.US, "%03d_", index) + safeName;
            addFileEntry(zos, file, entryName);
            manifest.append(escapeTsv(entryName)).append('\t')
                    .append(escapeTsv(path)).append('\t')
                    .append(escapeTsv(originalUri)).append('\t')
                    .append(escapeTsv(originalName)).append('\n');
            index++;
        }
        return manifest.toString();
    }

    private String escapeTsv(String value) {
        if (value == null) return "";
        return value.replace("\\", "\\\\").replace("\t", "\\t").replace("\n", "\\n").replace("\r", "");
    }

    private String unescapeTsv(String value) {
        if (value == null) return "";
        StringBuilder out = new StringBuilder();
        boolean esc = false;
        for (int i = 0; i < value.length(); i++) {
            char c = value.charAt(i);
            if (esc) {
                if (c == 't') out.append('\t');
                else if (c == 'n') out.append('\n');
                else out.append(c);
                esc = false;
            } else if (c == '\\') {
                esc = true;
            } else {
                out.append(c);
            }
        }
        if (esc) out.append('\\');
        return out.toString();
    }


    private void restoreDataArchiveFromUri(Uri uri, MethodChannel.Result result) {
        ZipInputStream zis = null;
        try {
            InputStream raw = getContentResolver().openInputStream(uri);
            if (raw == null) {
                result.success("{\"ok\":false,\"message\":\"无法读取 ZIP 文件\"}");
                return;
            }
            zis = new ZipInputStream(raw);
            File mediaDir = new File(getFilesDir(), "valora_media");
            if (!mediaDir.exists()) mediaDir.mkdirs();
            File restoreDir = new File(getFilesDir(), "valora_restore");
            if (!restoreDir.exists()) restoreDir.mkdirs();

            String backupJson = "";
            String mediaManifest = "";
            Map<String, String> mediaMap = new HashMap<>();
            Map<String, String> mediaEntryMap = new HashMap<>();
            int mediaCount = 0;
            int sqliteCount = 0;
            int totalEntries = 0;
            byte[] buf = new byte[8192];
            ZipEntry entry;
            while ((entry = zis.getNextEntry()) != null) {
                totalEntries++;
                String entryName = entry.getName() == null ? "" : entry.getName().replace("\\", "/");
                if (entry.isDirectory() || entryName.contains("..") || entryName.startsWith("/")) {
                    zis.closeEntry();
                    continue;
                }
                String lower = entryName.toLowerCase(java.util.Locale.US);
                if (lower.equals("backup/valora_backup.json") || lower.endsWith("/valora_backup.json") || lower.equals("valora_backup.json")) {
                    ByteArrayOutputStream bout = new ByteArrayOutputStream();
                    int n;
                    while ((n = zis.read(buf)) >= 0) bout.write(buf, 0, n);
                    backupJson = bout.toString("UTF-8");
                } else if (lower.equals("backup/media_manifest.tsv") || lower.endsWith("/media_manifest.tsv")) {
                    ByteArrayOutputStream bout = new ByteArrayOutputStream();
                    int n;
                    while ((n = zis.read(buf)) >= 0) bout.write(buf, 0, n);
                    mediaManifest = bout.toString("UTF-8");
                } else if (lower.startsWith("media/") || lower.contains("/media/")) {
                    String rawName = entryName.substring(entryName.lastIndexOf('/') + 1);
                    if (rawName.trim().length() == 0) {
                        zis.closeEntry();
                        continue;
                    }
                    String originalName = rawName.replaceFirst("^\\d{3}_", "").replaceAll("[^a-zA-Z0-9._-]", "_");
                    if (originalName.trim().length() == 0) originalName = "media_" + System.currentTimeMillis();
                    String outName = "restored_" + System.currentTimeMillis() + "_" + mediaCount + "_" + originalName;
                    File outFile = new File(mediaDir, outName);
                    FileOutputStream out = new FileOutputStream(outFile);
                    int n;
                    while ((n = zis.read(buf)) >= 0) out.write(buf, 0, n);
                    out.flush();
                    out.close();
                    String restoredUri = "file://" + outFile.getAbsolutePath();
                    mediaEntryMap.put(entryName, restoredUri);
                    mediaEntryMap.put(rawName, restoredUri);
                    mediaMap.put(originalName, restoredUri);
                    mediaMap.put(rawName, restoredUri);
                    String unsanitizedGuess = rawName.replaceFirst("^\\d{3}_", "");
                    mediaMap.put(unsanitizedGuess, restoredUri);
                    mediaCount++;
                } else if (lower.startsWith("sqlite/") || lower.contains("/sqlite/")) {
                    sqliteCount++;
                    while (zis.read(buf) >= 0) { /* drain entry */ }
                } else {
                    while (zis.read(buf) >= 0) { /* drain entry */ }
                }
                zis.closeEntry();
            }
            zis.close();
            zis = null;
            if (backupJson.trim().length() == 0) {
                result.success("{\"ok\":false,\"message\":\"ZIP 中没有找到 backup/valora_backup.json。请确认选择的是Valora导出的完整资料包，而不是普通压缩包。\"}");
                return;
            }
            applyMediaManifest(mediaManifest, mediaEntryMap, mediaMap);
            String rewrittenJson = rewriteArchiveMediaPaths(backupJson, mediaMap);
            File jsonFile = new File(restoreDir, "last_import_" + System.currentTimeMillis() + ".json");
            FileWriter fw = new FileWriter(jsonFile, false);
            fw.write(rewrittenJson);
            fw.flush();
            fw.close();
            String jsonPath = "file://" + jsonFile.getAbsolutePath();
            StringBuilder sb = new StringBuilder();
            sb.append("{\"ok\":true");
            sb.append(",\"message\":\"已读取完整资料包\"");
            sb.append(",\"mediaCount\":").append(mediaCount);
            sb.append(",\"sqliteCount\":").append(sqliteCount);
            sb.append(",\"entryCount\":").append(totalEntries);
            sb.append(",\"jsonSize\":").append(rewrittenJson.length());
            sb.append(",\"jsonPath\":\"").append(escape(jsonPath)).append("\"");
            // 小型备份直接回传，较大的备份让 Flutter 从 jsonPath 读取，避免 MethodChannel 大字符串不稳定。
            if (rewrittenJson.length() < 256000) {
                sb.append(",\"json\":\"").append(escape(rewrittenJson)).append("\"");
            }
            sb.append("}");
            result.success(sb.toString());
        } catch (Exception e) {
            result.success("{\"ok\":false,\"message\":\"" + escape(e.getMessage()) + "\"}");
        } finally {
            if (zis != null) {
                try { zis.close(); } catch (Exception ignored) {}
            }
        }
    }

    private void applyMediaManifest(String manifest, Map<String, String> mediaEntryMap, Map<String, String> mediaMap) {
        if (manifest == null || manifest.trim().length() == 0 || mediaEntryMap == null || mediaEntryMap.isEmpty()) return;
        String[] lines = manifest.split("\\r?\\n");
        for (int i = 1; i < lines.length; i++) {
            String line = lines[i];
            if (line == null || line.trim().length() == 0) continue;
            String[] parts = line.split("\\t", -1);
            if (parts.length < 4) continue;
            String entryName = unescapeTsv(parts[0]);
            String originalPath = unescapeTsv(parts[1]);
            String originalUri = unescapeTsv(parts[2]);
            String originalName = unescapeTsv(parts[3]);
            String restored = mediaEntryMap.get(entryName);
            if (restored == null) {
                String rawName = entryName.substring(entryName.lastIndexOf('/') + 1);
                restored = mediaEntryMap.get(rawName);
            }
            if (restored == null) continue;
            if (originalPath != null && originalPath.length() > 0) {
                mediaMap.put(originalPath, restored);
                mediaMap.put("file://" + originalPath, restored);
            }
            if (originalUri != null && originalUri.length() > 0) mediaMap.put(originalUri, restored);
            if (originalName != null && originalName.length() > 0) mediaMap.put(originalName, restored);
        }
    }

    private String readPrivateTextFile(String rawPath) {
        try {
            String path = rawPath == null ? "" : rawPath.trim();
            if (path.startsWith("file://")) path = Uri.parse(path).getPath();
            if (path.length() == 0) return "";
            File file = new File(path);
            File root = getFilesDir();
            String canonicalFile = file.getCanonicalPath();
            String canonicalRoot = root.getCanonicalPath();
            if (!canonicalFile.startsWith(canonicalRoot)) return "";
            FileInputStream in = new FileInputStream(file);
            ByteArrayOutputStream out = new ByteArrayOutputStream();
            byte[] buf = new byte[8192];
            int n;
            while ((n = in.read(buf)) >= 0) out.write(buf, 0, n);
            in.close();
            return out.toString("UTF-8");
        } catch (Exception e) {
            return "";
        }
    }


    private String rewriteArchiveMediaPaths(String json, Map<String, String> mediaMap) {
        if (json == null || json.length() == 0 || mediaMap == null || mediaMap.isEmpty()) return json == null ? "" : json;
        String result = json;
        // 1. 先做精确替换：v50 的 media_manifest.tsv 会提供旧设备完整 file:// 路径和绝对路径。
        List<Map.Entry<String, String>> entries = new ArrayList<>(mediaMap.entrySet());
        Collections.sort(entries, (a, b) -> Integer.compare(b.getKey() == null ? 0 : b.getKey().length(), a.getKey() == null ? 0 : a.getKey().length()));
        for (Map.Entry<String, String> item : entries) {
            String key = item.getKey();
            String restored = item.getValue();
            if (key == null || key.trim().length() == 0 || restored == null || restored.trim().length() == 0) continue;
            try {
                result = result.replace(key, restored);
            } catch (Exception ignored) {}
        }
        // 2. 再做旧版 ZIP 兼容：v49 没有 manifest，只能通过文件名尽量匹配旧绝对路径。
        for (Map.Entry<String, String> item : entries) {
            String fileName = item.getKey();
            String restored = item.getValue();
            if (fileName == null || fileName.trim().length() == 0 || restored == null) continue;
            if (fileName.contains("/") || fileName.contains("\\")) continue;
            String pattern = "(file://)?/[^\\\"\\\\]*" + Pattern.quote(fileName);
            try {
                result = result.replaceAll(pattern, Matcher.quoteReplacement(restored));
            } catch (Exception ignored) {}
        }
        return result;
    }


    private void shareText(String title, String text) {
        Intent send = new Intent(Intent.ACTION_SEND);
        send.setType("text/plain");
        send.putExtra(Intent.EXTRA_SUBJECT, title);
        send.putExtra(Intent.EXTRA_TEXT, text);
        startActivity(Intent.createChooser(send, title));
    }

    private String readClipboardText() {
        ClipboardManager cm = (ClipboardManager) getSystemService(Context.CLIPBOARD_SERVICE);
        if (cm == null || !cm.hasPrimaryClip()) return "";
        ClipData data = cm.getPrimaryClip();
        if (data == null || data.getItemCount() == 0) return "";
        CharSequence text = data.getItemAt(0).coerceToText(this);
        return text == null ? "" : text.toString();
    }

    private void writeClipboardText(String text) {
        ClipboardManager cm = (ClipboardManager) getSystemService(Context.CLIPBOARD_SERVICE);
        if (cm != null) cm.setPrimaryClip(ClipData.newPlainText("Valora", text));
    }

    private void scheduleNotification(String title, String text, long delayMillis) {
        Intent intent = new Intent(this, ReminderReceiver.class);
        intent.putExtra("title", title);
        intent.putExtra("text", text);
        PendingIntent pi = PendingIntent.getBroadcast(this, 7201, intent, PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);
        AlarmManager alarm = (AlarmManager) getSystemService(Context.ALARM_SERVICE);
        if (alarm != null) alarm.set(AlarmManager.RTC_WAKEUP, System.currentTimeMillis() + Math.max(3000L, delayMillis), pi);
    }

    private void cancelNotification() {
        Intent intent = new Intent(this, ReminderReceiver.class);
        PendingIntent pi = PendingIntent.getBroadcast(this, 7201, intent, PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);
        AlarmManager alarm = (AlarmManager) getSystemService(Context.ALARM_SERVICE);
        if (alarm != null) alarm.cancel(pi);
    }

    private boolean createDynamicShortcuts() {
        if (Build.VERSION.SDK_INT < 25) return false;
        ShortcutManager manager = getSystemService(ShortcutManager.class);
        if (manager == null) return false;
        Intent addAsset = new Intent(this, MainActivity.class).setAction("com.valora.assets.ADD_ASSET");
        Intent addWish = new Intent(this, MainActivity.class).setAction("com.valora.assets.ADD_WISH");
        ShortcutInfo s1 = new ShortcutInfo.Builder(this, "add_asset")
                .setShortLabel("新增资产")
                .setLongLabel("新增Valora资产")
                .setIcon(Icon.createWithResource(this, R.drawable.ic_shortcut_add))
                .setIntent(addAsset)
                .build();
        ShortcutInfo s2 = new ShortcutInfo.Builder(this, "add_wish")
                .setShortLabel("新增心愿")
                .setLongLabel("新增Valora心愿")
                .setIcon(Icon.createWithResource(this, R.drawable.ic_shortcut_wish))
                .setIntent(addWish)
                .build();
        manager.setDynamicShortcuts(Arrays.asList(s1, s2));
        return true;
    }

    @SuppressWarnings("unchecked")
    private void updateHomeWidget(Object arguments) {
        Map<String, Object> args = arguments instanceof Map ? (Map<String, Object>) arguments : new HashMap<>();
        SharedPreferences prefs = getSharedPreferences("valora_widget", Context.MODE_PRIVATE);
        prefs.edit()
                .putInt("assetCount", intArg(args.get("assetCount"), 0))
                .putInt("wishCount", intArg(args.get("wishCount"), 0))
                .putInt("servingCount", intArg(args.get("servingCount"), 0))
                .putInt("retiredCount", intArg(args.get("retiredCount"), 0))
                .putInt("soldCount", intArg(args.get("soldCount"), 0))
                .putInt("dueSoonCount", intArg(args.get("dueSoonCount"), 0))
                .putInt("leakCount", intArg(args.get("leakCount"), 0))
                .putInt("snapshotCount", intArg(args.get("snapshotCount"), 0))
                .putString("currency", arg(args.get("currency"), "¥"))
                .putString("totalAssetValue", String.format(java.util.Locale.US, "%.2f", doubleArg(args.get("totalAssetValue"), 0)))
                .putString("averageDailyCost", String.format(java.util.Locale.US, "%.2f", doubleArg(args.get("averageDailyCost"), 0)))
                .apply();
        AppWidgetManager appWidgetManager = AppWidgetManager.getInstance(this);
        ValoraWidgetProvider.updateAll(this, appWidgetManager);
        ValoraWishWidgetProvider.updateAll(this, appWidgetManager);
        ValoraDailyWidgetProvider.updateAll(this, appWidgetManager);
        ValoraHealthWidgetProvider.updateAll(this, appWidgetManager);
        ValoraQuickWidgetProvider.updateAll(this, appWidgetManager);
        ValoraDueWidgetProvider.updateAll(this, appWidgetManager);
        ValoraSnapshotWidgetProvider.updateAll(this, appWidgetManager);
    }

    private boolean requestNotificationPermission() {
        if (Build.VERSION.SDK_INT >= 33) {
            requestPermissions(new String[]{Manifest.permission.POST_NOTIFICATIONS}, 7901);
            return true;
        }
        return false;
    }

    private void openNotificationSettings() {
        Intent intent;
        if (Build.VERSION.SDK_INT >= 26) {
            intent = new Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS);
            intent.putExtra(Settings.EXTRA_APP_PACKAGE, getPackageName());
        } else {
            intent = new Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.parse("package:" + getPackageName()));
        }
        startActivity(intent);
    }

    private void openAppSettings() {
        startActivity(new Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.parse("package:" + getPackageName())));
    }

    private String intentToJson(Intent intent) {
        if (intent == null) return "";
        String action = intent.getAction();
        String type = intent.getType();
        String text = intent.getStringExtra(Intent.EXTRA_TEXT);
        Uri uri = intent.getData();
        if (uri == null && intent.getClipData() != null && intent.getClipData().getItemCount() > 0) {
            uri = intent.getClipData().getItemAt(0).getUri();
        }
        return "{"
                + "\"action\":\"" + escape(action) + "\","
                + "\"type\":\"" + escape(type) + "\","
                + "\"text\":\"" + escape(text) + "\","
                + "\"uri\":\"" + escape(uri == null ? null : uri.toString()) + "\""
                + "}";
    }

    private String escape(String value) {
        if (value == null) return "";
        return value.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "");
    }

    private String arg(Object value, String fallback) { return value == null ? fallback : String.valueOf(value); }
    private int intArg(Object value, int fallback) { try { return value instanceof Number ? ((Number) value).intValue() : Integer.parseInt(String.valueOf(value)); } catch (Exception e) { return fallback; } }
    private long longArg(Object value, long fallback) { try { return value instanceof Number ? ((Number) value).longValue() : Long.parseLong(String.valueOf(value)); } catch (Exception e) { return fallback; } }
    private double doubleArg(Object value, double fallback) { try { return value instanceof Number ? ((Number) value).doubleValue() : Double.parseDouble(String.valueOf(value)); } catch (Exception e) { return fallback; } }
}
