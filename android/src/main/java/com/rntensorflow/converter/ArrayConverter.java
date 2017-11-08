package com.rntensorflow.converter;

import com.facebook.react.bridge.ReadableArray;
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

    public static float[] readableArrayToFloatArray(ReadableArray readableArray) {
        float[] arr = new float[readableArray.size()];
        for (int i = 0; i < readableArray.size(); i++) {
            arr[i] = (float)readableArray.getDouble(i);
        }

        return arr;
    }

    public static int[] readableArrayToIntArray(ReadableArray readableArray) {
        int[] arr = new int[readableArray.size()];
        for (int i = 0; i < readableArray.size(); i++) {
            arr[i] = readableArray.getInt(i);
        }

        return arr;
    }

    public static byte[] readableArrayToByteBoolArray(ReadableArray readableArray) {
        byte[] arr = new byte[readableArray.size()];
        for (int i = 0; i < readableArray.size(); i++) {
            arr[i] = (byte)(readableArray.getBoolean(i) ? 1 : 0);
        }

        return arr;
    }

    public static byte[] readableArrayToByteStringArray(ReadableArray readableArray) {
        byte[] arr = new byte[readableArray.size()];
        for (int i = 0; i < readableArray.size(); i++) {
            arr[i] = Byte.valueOf(readableArray.getString(i));
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
