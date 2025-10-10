#!/bin/bash

echo "Granting storage permissions for com.visualit.app.visualit..."
echo ""

echo "Granting READ_EXTERNAL_STORAGE..."
adb shell pm grant com.visualit.app.visualit android.permission.READ_EXTERNAL_STORAGE

echo "Granting WRITE_EXTERNAL_STORAGE..."
adb shell pm grant com.visualit.app.visualit android.permission.WRITE_EXTERNAL_STORAGE

echo "Granting MANAGE_EXTERNAL_STORAGE (Android 11+)..."
adb shell appops set com.visualit.app.visualit MANAGE_EXTERNAL_STORAGE allow

echo ""
echo "Granting media permissions (Android 13+)..."
adb shell pm grant com.visualit.app.visualit android.permission.READ_MEDIA_IMAGES
adb shell pm grant com.visualit.app.visualit android.permission.READ_MEDIA_VIDEO
adb shell pm grant com.visualit.app.visualit android.permission.READ_MEDIA_AUDIO

echo ""
echo "==================================="
echo "All permissions granted successfully!"
echo "==================================="