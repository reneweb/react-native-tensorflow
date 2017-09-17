package com.rntensorflow.converter;

import com.facebook.react.bridge.ReadableNativeArray;
import com.facebook.react.bridge.WritableNativeArray;

public class ArrayConverter {

    public static String[] nativeArrayToStringArray(ReadableNativeArray nativeArray) {
        String[] arr = new String[nativeArray.size()];
        for (int i = 0; i < nativeArray.size(); i++) {
            arr[i] = nativeArray.getString(i);
        }

        return arr;
    }

    public static double[] nativeArrayToDoubleArray(ReadableNativeArray nativeArray) {
        double[] arr = new double[nativeArray.size()];
        for (int i = 0; i < nativeArray.size(); i++) {
            arr[i] = nativeArray.getDouble(i);
        }

        return arr;
    }

    public static long[] nativeArrayToLongArray(ReadableNativeArray nativeArray) {
        long[] arr = new long[nativeArray.size()];
        for (int i = 0; i < nativeArray.size(); i++) {
            arr[i] = (long)nativeArray.getDouble(i);
        }

        return arr;
    }

    public static ReadableNativeArray stringArrayToNativeArray(String[] arr) {
        WritableNativeArray nativeArray = new WritableNativeArray();
        for (int i = 0; i < arr.length; i++) {
            nativeArray.pushString(arr[i]);
        }

        return nativeArray;
    }

    public static ReadableNativeArray doubleArrayToNativeArray(double[] arr) {
        WritableNativeArray nativeArray = new WritableNativeArray();
        for (int i = 0; i < arr.length; i++) {
            nativeArray.pushDouble(arr[i]);
        }

        return nativeArray;
    }

    public static ReadableNativeArray longArrayToNativeArray(long[] arr) {
        WritableNativeArray nativeArray = new WritableNativeArray();
        for (int i = 0; i < arr.length; i++) {
            nativeArray.pushDouble(arr[i]);
        }

        return nativeArray;
    }
}
