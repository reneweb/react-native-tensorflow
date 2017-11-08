package com.rntensorflow.converter;

import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableNativeArray;

import java.util.ArrayList;
import java.util.List;

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
        byte[] bytesArr = new byte[readableArray.size() / 8 + 1];
        for (int entry = 0; entry < bytesArr.length; entry++) {
            for (int bit = 0; bit < 8; bit++) {
                if (readableArray.getBoolean(entry * 8 + bit)) {
                    bytesArr[entry] |= (128 >> bit);
                }
            }
        }

        return bytesArr;
    }

    public static byte[] readableArrayToByteStringArray(ReadableArray readableArray) {
        List<Byte> bytes = new ArrayList<>(readableArray.size() * 5);
        for (int i = 0; i < readableArray.size(); i++) {
            for (byte b :readableArray.getString(i).getBytes()) {
                bytes.add(b);
            }
        }

        byte[] bytesArr = new byte[bytes.size()];
        for (int i = 0; i < bytes.size(); i++) {
            bytesArr[i] = bytes.get(i);
        }

        return bytesArr;
    }

    public static ReadableArray doubleArrayToReadableArray(double[] arr) {
        WritableArray writableArray = new WritableNativeArray();
        for (double d : arr) {
            writableArray.pushDouble(d);
        }

        return writableArray;
    }

    public static ReadableArray floatArrayToReadableArray(float[] arr) {
        WritableArray writableArray = new WritableNativeArray();
        for (float f : arr) {
            writableArray.pushDouble(f);
        }

        return writableArray;
    }

    public static ReadableArray intArrayToReadableArray(int[] arr) {
        WritableArray writableArray = new WritableNativeArray();
        for (int i : arr) {
            writableArray.pushInt(i);
        }

        return writableArray;
    }

    public static ReadableArray byteArrayToBoolReadableArray(byte[] arr) {
        WritableArray writableArray = new WritableNativeArray();
        byte[] pos = new byte[]{(byte)0x80, 0x40, 0x20, 0x10, 0x8, 0x4, 0x2, 0x1};

        for(int i = 0; i < arr.length; i++){
            for(int k = 0; k < 8; k++){
                boolean res = (arr[i] & pos[k]) != 0;
                writableArray.pushBoolean(res);
            }
        }

        return writableArray;
    }
}
