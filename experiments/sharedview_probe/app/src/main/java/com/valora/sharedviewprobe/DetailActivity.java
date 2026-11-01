package com.valora.sharedviewprobe;

import android.app.Activity;
import android.graphics.Color;
import android.graphics.Rect;
import android.os.Bundle;
import android.util.Log;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.itgsa.animation.sharedview.ViewAnimationConfig;
import com.itgsa.animation.sharedview.ViewAnimationManager;

public final class DetailActivity extends Activity {
    private static final String TAG = "ValoraSharedViewProbe";
    private boolean overrideAttempted;

    @Override
    public void onCreate(Bundle state) {
        super.onCreate(state);
        LinearLayout content = new LinearLayout(this);
        content.setOrientation(LinearLayout.VERTICAL);
        int padding = Math.round(24 * getResources().getDisplayMetrics().density);
        content.setPadding(padding, padding * 2, padding, padding);
        content.setBackgroundColor(Color.WHITE);

        TextView title = new TextView(this);
        title.setTextSize(24);
        title.setTextColor(Color.DKGRAY);
        title.setText("详情页\n\n请求：" + getIntent().getStringExtra("requestedMode")
                + "\n准备方式：" + getIntent().getStringExtra("preparedMode")
                + "\n实际动画请结合屏幕和回调日志确认。"
                + "\n\n请测试按钮返回、系统返回手势以及取消手势。");
        content.addView(title);

        Button back = new Button(this);
        back.setText("返回");
        back.setOnClickListener(view -> finish());
        content.addView(back);
        setContentView(content);
    }

    @Override
    public void finish() {
        if (!overrideAttempted && getIntent().getBooleanExtra("kitStarted", false)) {
            overrideAttempted = true;
            boolean geometryUnchanged = getIntent().getIntExtra("orientation", -1)
                    == getResources().getConfiguration().orientation
                    && getIntent().getIntExtra("width", -1) == getResources().getDisplayMetrics().widthPixels
                    && getIntent().getIntExtra("height", -1) == getResources().getDisplayMetrics().heightPixels;
            Rect bounds = getIntent().getParcelableExtra("bounds");
            if (geometryUnchanged && bounds != null && !bounds.isEmpty()) {
                try {
                    ViewAnimationManager.overrideViewAnimationTransition(this,
                            new ViewAnimationConfig().setBounds(bounds).toBundle());
                } catch (RuntimeException | LinkageError error) {
                    Log.w(TAG, "Return override failed; continuing to finish", error);
                }
            } else {
                Log.w(TAG, "Window geometry changed; skipped stale return bounds");
            }
        }
        super.finish();
    }
}
