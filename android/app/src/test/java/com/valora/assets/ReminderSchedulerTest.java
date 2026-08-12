package com.valora.assets;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotEquals;
import static org.junit.Assert.assertTrue;

import java.util.Arrays;
import java.util.List;
import org.junit.Test;

public class ReminderSchedulerTest {
    @Test
    public void buildsIndependentFutureReminderIdentities() {
        List<ReminderScheduler.ReminderSpec> specs = ReminderScheduler.buildSpecs(
                true,
                Arrays.asList(
                        new ReminderScheduler.ReminderInput(
                                "asset:a:expiry", "a", "expiry", 4102531200000L,
                                "Valora", "A", true),
                        new ReminderScheduler.ReminderInput(
                                "asset:b:expiry", "b", "expiry", 4102531200000L,
                                "Valora", "B", true)),
                0L);

        assertEquals(2, specs.size());
        assertNotEquals(specs.get(0).notificationId, specs.get(1).notificationId);
        assertNotEquals(specs.get(0).id, specs.get(1).id);
        assertEquals(specs.get(0).notificationId,
                ReminderScheduler.notificationIdFor(specs.get(0).id));
    }

    @Test
    public void ignoresDisabledPastAndDuplicateRecords() {
        List<ReminderScheduler.ReminderSpec> specs = ReminderScheduler.buildSpecs(
                true,
                Arrays.asList(
                        new ReminderScheduler.ReminderInput(
                                "future", "", "expiry", 4102531200000L,
                                "Valora", "", true),
                        new ReminderScheduler.ReminderInput(
                                "future", "", "expiry", 4102531200000L,
                                "Valora", "", true),
                        new ReminderScheduler.ReminderInput(
                                "past", "", "expiry", 1000L,
                                "Valora", "", true),
                        new ReminderScheduler.ReminderInput(
                                "disabled", "", "expiry", 4102531200000L,
                                "Valora", "", false)),
                1700000000000L);

        assertEquals(1, specs.size());
        assertEquals("future", specs.get(0).id);
    }

    @Test
    public void disabledGlobalSettingProducesNoSchedules() {
        assertTrue(ReminderScheduler.buildSpecs(
                false,
                Arrays.asList(new ReminderScheduler.ReminderInput(
                        "future", "", "expiry", 4102531200000L,
                        "Valora", "", true)),
                0L).isEmpty());
    }

    @Test
    public void notificationIdentityIsStableForAlarmRestoration() {
        ReminderScheduler.ReminderSpec original = new ReminderScheduler.ReminderSpec(
                "asset:stable:expiry", "stable", "expiry", 4102444800000L,
                "Valora", "Review stable");

        assertEquals(original.notificationId,
                ReminderScheduler.notificationIdFor(original.id));
        assertEquals(original.notificationId,
                ReminderScheduler.notificationIdFor("asset:stable:expiry"));
    }
}
