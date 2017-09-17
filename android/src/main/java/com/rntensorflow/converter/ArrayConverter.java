package com.rntensorflow.converter;

import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableNativeArray;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableNativeArray;

public class ArrayConverter {

    public static String[] readableArrayToStringArray(ReadableArray readableArray) {
        String[] arr = new String[readableArray.size()];
        for (int i = 0; i < readableArray.size(); i++) {
            arr[i] = readableArray.getString(i);
        }

        return arr;
    }

    public static double[] readableArrayToDoubleArray(ReadableArray readableArray) {
        double[] arr = new double[readableArray.size()];
        for (int i = 0; i < readableArray.size(); i++) {
            arr[i] = readableArray.getDouble(i);
        }

        return arr;
    }

    public static long[] readableArrayToLongArray(ReadableArray readableArray) {
        long[] arr = new long[readableArray.size()];
        for (int i = 0; i < readableArray.size(); i++) {
            arr[i] = (long)readableArray.getDouble(i);
        }

        return arr;
    }

    public static ReadableArray stringArrayToReadableArray(String[] arr) {
        WritableArray writableArray = new WritableNativeArray();
        for (int i = 0; i < arr.length; i++) {
            writableArray.pushString(arr[i]);
        }

        return writableArray;
    }

    public static ReadableArray doubleArrayToReadableArray(double[] arr) {
        WritableArray writableArray = new WritableNativeArray();
        for (int i = 0; i < arr.length; i++) {
            writableArray.pushDouble(arr[i]);
        }

        return writableArray;
    }

    public static ReadableArray longArrayToReadableArray(long[] arr) {
        WritableArray writableArray = new WritableNativeArray();
        for (int i = 0; i < arr.length; i++) {
            writableArray.pushDouble(arr[i]);
        }

        return writableArray;
    }
}
