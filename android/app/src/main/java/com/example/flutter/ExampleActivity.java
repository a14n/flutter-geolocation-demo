// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.example.flutter;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.os.Bundle;
import android.util.Log;

import org.chromium.base.PathUtils;

import io.flutter.view.FlutterMain;
import io.flutter.view.FlutterView;

import java.io.File;

import org.json.JSONException;
import org.json.JSONObject;

public class ExampleActivity extends Activity {
    private static final String TAG = "ExampleActivity";

    private FlutterView flutterView;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        FlutterMain.ensureInitializationComplete(getApplicationContext(), null);
        setContentView(R.layout.flutter_layout);

        flutterView = (FlutterView) findViewById(R.id.flutter_view);
        File appBundle = new File(PathUtils.getDataDirectory(this), FlutterMain.APP_BUNDLE);
        flutterView.runFromBundle(appBundle.getPath(), null);
        requestLocationUpdates();


    }

    private void requestLocationUpdates() {
        // Acquire a reference to the system Location Manager
        LocationManager locationManager = (LocationManager) this.getSystemService(Context.LOCATION_SERVICE);

        // Define a listener that responds to location updates
        LocationListener locationListener = new LocationListener() {
            public void onLocationChanged(Location location) {
                JSONObject locationAsJson = new JSONObject();
                try {
                    locationAsJson.put("accuracy", location.getAccuracy());
                    locationAsJson.put("provider", location.getProvider());
                    locationAsJson.put("latitude", location.getLatitude());
                    locationAsJson.put("longitude", location.getLongitude());
                    locationAsJson.put("time", location.getTime());
                } catch (JSONException e) {
                    Log.e(TAG, "JSON exception", e);
                    return;
                }
                flutterView.sendToFlutter("locations", locationAsJson.toString(), null);
            }

            public void onStatusChanged(String provider, int status, Bundle extras) {
            }

            public void onProviderEnabled(String provider) {
            }

            public void onProviderDisabled(String provider) {
            }
        };

        // Register the listener with the Location Manager to receive location updates
        locationManager.requestLocationUpdates(LocationManager.NETWORK_PROVIDER, 0, 0, locationListener);
    }

    @Override
    protected void onDestroy() {
        if (flutterView != null) {
            flutterView.destroy();
        }
        super.onDestroy();
    }

    @Override
    protected void onPause() {
        super.onPause();
        flutterView.onPause();
    }

    @Override
    protected void onResume() {
        super.onResume();
        flutterView.onResume();
    }

    @Override
    protected void onNewIntent(Intent intent) {
        // Reload the Flutter Dart code when the activity receives an intent
        // from the "flutter refresh" command.
        // This feature should only be enabled during development.  Use the
        // debuggable flag as an indicator that we are in development mode.
        if ((getApplicationInfo().flags & ApplicationInfo.FLAG_DEBUGGABLE) != 0) {
            if (Intent.ACTION_RUN.equals(intent.getAction())) {
                flutterView.runFromBundle(intent.getDataString(),
                        intent.getStringExtra("snapshot"));
            }
        }
    }
}
