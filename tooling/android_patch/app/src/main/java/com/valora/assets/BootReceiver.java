package com.valora.assets;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

public class BootReceiver extends BroadcastReceiver {
    @Override
    public void onReceive(Context context, Intent intent) {
        // Reserved for restoring long-term reminder schedules after reboot.
        // Current v11 schedules test reminders from Flutter on demand.
    }
}
