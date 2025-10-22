package com.dexterous.flutterlocalnotifications;

import static android.content.Context.POWER_SERVICE;

import android.app.Activity;
import android.app.AlarmManager;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationChannelGroup;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.media.AudioAttributes;
import android.media.RingtoneManager;
import android.net.Uri;
import android.os.Build;
import android.os.PowerManager;
import android.service.notification.StatusBarNotification;
import android.text.Html;
import android.text.Spanned;

import androidx.annotation.Keep;
import androidx.annotation.NonNull;
import androidx.core.app.AlarmManagerCompat;
import androidx.core.app.NotificationCompat;
import androidx.core.app.NotificationCompat.Action;
import androidx.core.app.NotificationCompat.AndroidResources;
import androidx.core.app.NotificationManagerCompat;
import androidx.core.app.Person;
import androidx.core.app.RemoteInput;
import androidx.core.content.ContextCompat;
import androidx.core.graphics.drawable.IconCompat;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;
import androidx.work.BackoffPolicy;
import androidx.work.Constraints;
import androidx.work.Data;
import androidx.work.ExistingPeriodicWorkPolicy;
import androidx.work.ExistingWorkPolicy;
import androidx.work.ListenableWorker;
import androidx.work.NetworkType;
import androidx.work.OneTimeWorkRequest;
import androidx.work.OutOfQuotaPolicy;
import androidx.work.PeriodicWorkRequest;
import androidx.work.WorkManager;

import com.dexterous.flutterlocalnotifications.isolate.IsolatePreferences;
import com.dexterous.flutterlocalnotifications.models.DateTimeComponents;
import com.dexterous.flutterlocalnotifications.models.IconSource;
import com.dexterous.flutterlocalnotifications.models.MessageDetails;
import com.dexterous.flutterlocalnotifications.models.NotificationAction;
import com.dexterous.flutterlocalnotifications.models.NotificationChannelAction;
import com.dexterous.flutterlocalnotifications.models.NotificationChannelDetails;
import com.dexterous.flutterlocalnotifications.models.NotificationChannelGroupDetails;
import com.dexterous.flutterlocalnotifications.models.NotificationDetails;
import com.dexterous.flutterlocalnotifications.models.NotificationStyle;
import com.dexterous.flutterlocalnotifications.models.PersonDetails;
import com.dexterous.flutterlocalnotifications.models.ScheduleMode;
import com.dexterous.flutterlocalnotifications.models.ScheduledNotificationRepeatFrequency;
import com.dexterous.flutterlocalnotifications.models.ScheduledNotificationTimeUnit;
import com.dexterous.flutterlocalnotifications.models.ScheduledNotificationTimeUnitFrequency;
import com.dexterous.flutterlocalnotifications.models.SoundSource;
import com.dexterous.flutterlocalnotifications.models.styles.BigPictureStyleInformation;
import com.dexterous.flutterlocalnotifications.models.styles.BigTextStyleInformation;
import com.dexterous.flutterlocalnotifications.models.styles.DefaultStyleInformation;
import com.dexterous.flutterlocalnotifications.models.styles.InboxStyleInformation;
import com.dexterous.flutterlocalnotifications.models.styles.MessagingStyleInformation;
import com.dexterous.flutterlocalnotifications.repeatnotifications.ScheduledNotificationBootReceiver;
import com.dexterous.flutterlocalnotifications.repeatnotifications.ScheduledNotificationReceiver;
import com.dexterous.flutterlocalnotifications.utils.BooleanUtils;
import com.dexterous.flutterlocalnotifications.utils.LongUtils;
import com.dexterous.flutterlocalnotifications.utils.StringUtils;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.reflect.TypeToken;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.lang.reflect.Type;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.concurrent.TimeUnit;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.view.FlutterCallbackInformation;

// THE FIX: We need to provide explicit types for bigLargeIcon method calls
public class FlutterLocalNotificationsPlugin implements MethodCallHandler, FlutterPlugin, ActivityAware {
    // ... keep all existing code ...

    // THE FIX: Modify this method to fix the ambiguity
    private static void configureBigPictureNotificationStyle(
            Context context, NotificationDetails notificationDetails,
            NotificationCompat.Builder builder, String drawableResourcePath) {
        BigPictureStyleInformation bigPictureStyleInformation =
                (BigPictureStyleInformation) notificationDetails.styleInformation;
        NotificationCompat.BigPictureStyle bigPictureStyle = new NotificationCompat.BigPictureStyle();
        if (bigPictureStyleInformation.contentTitle != null) {
            CharSequence contentTitle =
                    bigPictureStyleInformation.htmlFormatContentTitle
                            ? fromHtml(bigPictureStyleInformation.contentTitle)
                            : bigPictureStyleInformation.contentTitle;
            bigPictureStyle.setBigContentTitle(contentTitle);
        }
        if (bigPictureStyleInformation.summaryText != null) {
            CharSequence summaryText =
                    bigPictureStyleInformation.htmlFormatSummaryText
                            ? fromHtml(bigPictureStyleInformation.summaryText)
                            : bigPictureStyleInformation.summaryText;
            bigPictureStyle.setSummaryText(summaryText);
        }

        if (bigPictureStyleInformation.hideExpandedLargeIcon) {
            // THE FIX: Use explicit Bitmap type to avoid ambiguity
            bigPictureStyle.bigLargeIcon((Bitmap) null);
        }

        // Continue with existing code for bigPicture
    }
}
