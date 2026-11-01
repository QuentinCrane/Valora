package com.valora.sharedviewprobe;

import android.app.Activity;
import android.app.ActivityOptions;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Rect;
import android.graphics.drawable.GradientDrawable;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.itgsa.animation.sharedview.ViewAnimationConfig;
import com.itgsa.animation.sharedview.ViewAnimationExtras;
import com.itgsa.animation.sharedview.ViewAnimationListener;
import com.itgsa.animation.sharedview.ViewAnimationManager;

import java.util.Locale;
import java.util.Map;

/** Independent native SDK probe. It does not attach to the Valora Flutter engine. */
public final class MainActivity extends Activity {
    private static final String TAG = "ValoraSharedViewProbe";
    private static final int PAGE_COLOR = Color.rgb(246, 249, 252);
    private TextView status;
    private TextView source;
    private Bitmap activeBitmap;
    private ViewAnimationListener activeListener;

    @Override
    public void onCreate(Bundle state) {
        super.onCreate(state);
        LinearLayout content = new LinearLayout(this);
        content.setOrientation(LinearLayout.VERTICAL);
        content.setPadding(dp(24), dp(48), dp(24), dp(24));
        content.setBackgroundColor(PAGE_COLOR);

        status = new TextView(this);
        status.setTextColor(Color.DKGRAY);
        status.setTextSize(16);
        content.addView(status);

        source = new TextView(this);
        source.setText("资产卡片示例\n\n点击下方按钮测试转场");
        source.setTextColor(Color.rgb(22, 45, 67));
        source.setTextSize(21);
        source.setPadding(dp(24), dp(24), dp(24), dp(24));
        GradientDrawable card = new GradientDrawable();
        card.setColor(Color.rgb(205, 233, 248));
        card.setCornerRadius(dp(24));
        source.setBackground(card);
        source.setClipToOutline(true);
        LinearLayout.LayoutParams cardParams = new LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT, dp(180));
        cardParams.setMargins(0, dp(24), 0, dp(16));
        content.addView(source, cardParams);

        addButton(content, "SharedView：View 起点", () -> open("view"));
        addButton(content, "SharedView：Bitmap 起点", () -> open("bitmap"));
        addButton(content, "Android 默认转场", () -> open("system"));
        setContentView(content);
    }

    @Override
    protected void onResume() {
        super.onResume();
        int protocol = supportedProtocol();
        status.setText(protocol > 0
                ? "设备声明支持 SharedView，协议版本：" + protocol
                : "设备未声明支持 SharedView，测试将使用 Android 默认转场");
    }

    private int supportedProtocol() {
        try {
            return ViewAnimationManager.isViewAnimationSupported();
        } catch (RuntimeException | LinkageError error) {
            Log.w(TAG, "Capability query failed", error);
            return 0;
        }
    }

    private void open(String mode) {
        Intent intent = new Intent(this, DetailActivity.class);
        intent.putExtra("requestedMode", mode);
        ActivityOptions options = null;
        if (!"system".equals(mode) && supportedProtocol() > 0
                && source.isAttachedToWindow() && source.getWidth() > 0 && source.getHeight() > 0) {
            try {
                Map<String, String> extras = ViewAnimationManager.getViewAnimationExtras();
                boolean windowCoordinates = usesWindowCoordinates(extras);
                Rect bounds = sourceBounds(windowCoordinates);
                float radius = dp(24);
                Bundle config = new ViewAnimationConfig()
                        .setRadius(radius)
                        .setColor(PAGE_COLOR)
                        .toBundle();
                activeListener = new ViewAnimationListener() {
                    @Override public void onAnimationStart(int animationMode) {
                        Log.i(TAG, "animation start: " + animationMode);
                    }
                    @Override public void onAnimationEnd(int animationMode) {
                        Log.i(TAG, "animation end: " + animationMode);
                    }
                    @Override public void onAnimationCancel(int animationMode) {
                        Log.i(TAG, "animation cancelled: " + animationMode);
                    }
                };
                if ("bitmap".equals(mode)) {
                    activeBitmap = Bitmap.createBitmap(source.getWidth(), source.getHeight(),
                            Bitmap.Config.ARGB_8888);
                    source.draw(new Canvas(activeBitmap));
                    options = ViewAnimationManager.makeViewAnimationOptions(
                            activeBitmap, bounds, radius, config, activeListener);
                } else {
                    options = ViewAnimationManager.makeViewAnimationOptions(source, config, activeListener);
                }
                if (options != null) {
                    intent.putExtra("kitStarted", true);
                    intent.putExtra("bounds", bounds);
                    intent.putExtra("orientation", getResources().getConfiguration().orientation);
                    intent.putExtra("width", getResources().getDisplayMetrics().widthPixels);
                    intent.putExtra("height", getResources().getDisplayMetrics().heightPixels);
                    Log.i(TAG, "Prepared " + mode + " source; coordinates="
                            + (windowCoordinates ? "window" : "screen") + ", bounds=" + bounds);
                } else {
                    Log.w(TAG, "SDK returned null options; falling back to Android transition");
                }
            } catch (RuntimeException | LinkageError error) {
                Log.w(TAG, "SDK preparation failed; falling back to Android transition", error);
            }
        }
        intent.putExtra("preparedMode", options == null ? "system" : mode);
        if (options == null) {
            startActivity(intent);
        } else {
            try {
                startActivity(intent, options.toBundle());
            } catch (RuntimeException error) {
                Log.w(TAG, "SDK launch failed; falling back to Android transition", error);
                intent.putExtra("kitStarted", false);
                intent.putExtra("preparedMode", "system");
                startActivity(intent);
            }
        }
    }

    private boolean usesWindowCoordinates(Map<String, String> extras) {
        String value = extras == null ? null : extras.get(ViewAnimationExtras.EXTRA_BOUNDS);
        if (value == null) return false;
        String[] tokens = value.split("\\|");
        if (tokens.length > 1) {
            String coordinate = tokens[1].trim().toUpperCase(Locale.ROOT);
            if ("WINDOW".equals(coordinate)) return true;
            if ("SCREEN".equals(coordinate)) return false;
        }
        return value.toUpperCase(Locale.ROOT).contains("WINDOW");
    }

    private Rect sourceBounds(boolean windowCoordinates) {
        int[] location = new int[2];
        if (windowCoordinates) source.getLocationInWindow(location);
        else source.getLocationOnScreen(location);
        return new Rect(location[0], location[1], location[0] + source.getWidth(),
                location[1] + source.getHeight());
    }

    private void addButton(LinearLayout parent, String label, Runnable action) {
        Button button = new Button(this);
        button.setText(label);
        button.setOnClickListener(view -> action.run());
        parent.addView(button);
    }

    private int dp(int value) {
        return Math.round(value * getResources().getDisplayMetrics().density);
    }
}
