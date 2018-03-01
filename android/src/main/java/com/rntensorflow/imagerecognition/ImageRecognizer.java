package com.rntensorflow.imagerecognition;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Matrix;
import com.facebook.react.bridge.*;
import com.rntensorflow.RNTensorflowInference;
import com.rntensorflow.ResourceManager;
import org.tensorflow.Tensor;

import java.io.IOException;
import java.nio.FloatBuffer;
import java.util.*;

public class ImageRecognizer {


    private static final int IMAGE_MEAN = 117;
    private static final float IMAGE_STD = 1;

    private static final int MAX_RESULTS = 3;
    private static final float THRESHOLD = 0.1f;

    private RNTensorflowInference inference;
    private ResourceManager resourceManager;

    private int imageMean;
    private float imageStd;

    private String[] labels;

    public ImageRecognizer(RNTensorflowInference inference, ResourceManager resourceManager,
                           int imageMean, float imageStd, String[] labels) {
        this.inference = inference;
        this.resourceManager = resourceManager;
        this.imageMean = imageMean;
        this.imageStd = imageStd;
        this.labels = labels;
    }

    public static ImageRecognizer init(
            ReactContext reactContext,
            String modelFilename,
            String labelFilename,
            Integer imageMean,
            Double imageStd) throws IOException {
        Integer imageMeanResolved = imageMean != null ? imageMean : IMAGE_MEAN;
        Float imageStdResolved = imageStd != null ? imageStd.floatValue() : IMAGE_STD;

        RNTensorflowInference inference = RNTensorflowInference.init(reactContext, modelFilename);
        ResourceManager resourceManager = new ResourceManager(reactContext);
        String[] labels = resourceManager.loadResourceAsString(labelFilename).split("\\r?\\n");
        return new ImageRecognizer(inference, resourceManager, imageMeanResolved, imageStdResolved, labels);
    }

    public WritableArray recognizeImage(final String image,
                                        final String inputName,
                                        final Integer inputSize,
                                        final String outputName,
                                        final Integer maxResults,
                                        final Double threshold) {

        String inputNameResolved = inputName != null ? inputName : "input";
        String outputNameResolved = outputName != null ? outputName : "output";
        Integer maxResultsResolved = maxResults != null ? maxResults : MAX_RESULTS;
        Float thresholdResolved = threshold != null ? threshold.floatValue() : THRESHOLD;

        Bitmap bitmapRaw = loadImage(resourceManager.loadResource(image));

        int inputSizeResolved = inputSize != null ? inputSize : 224;
        int[] intValues = new int[inputSizeResolved * inputSizeResolved];
        float[] floatValues = new float[inputSizeResolved * inputSizeResolved * 3];

        Bitmap bitmap = Bitmap.createBitmap(inputSizeResolved, inputSizeResolved, Bitmap.Config.ARGB_8888);
        Matrix matrix = createMatrix(bitmapRaw.getWidth(), bitmapRaw.getHeight(), inputSizeResolved, inputSizeResolved);
        final Canvas canvas = new Canvas(bitmap);
        canvas.drawBitmap(bitmapRaw, matrix, null);
        bitmap.getPixels(intValues, 0, bitmap.getWidth(), 0, 0, bitmap.getWidth(), bitmap.getHeight());
        for (int i = 0; i < intValues.length; ++i) {
            final int val = intValues[i];
            floatValues[i * 3 + 0] = (((val >> 16) & 0xFF) - imageMean) / imageStd;
            floatValues[i * 3 + 1] = (((val >> 8) & 0xFF) - imageMean) / imageStd;
            floatValues[i * 3 + 2] = ((val & 0xFF) - imageMean) / imageStd;
        }
        Tensor tensor = Tensor.create(new long[]{1, inputSizeResolved, inputSizeResolved, 3}, FloatBuffer.wrap(floatValues));
        inference.feed(inputNameResolved, tensor);
        inference.run(new String[] {outputNameResolved}, false);
        ReadableArray outputs = inference.fetch(outputNameResolved);

        List<WritableMap> results = new ArrayList<>();
        for (int i = 0; i < outputs.size(); ++i) {
            if (outputs.getDouble(i) > thresholdResolved) {
                WritableMap entry = new WritableNativeMap();
                entry.putString("id", String.valueOf(i));
                entry.putString("name", labels.length > i ? labels[i] : "unknown");
                entry.putDouble("confidence", outputs.getDouble(i));
                results.add(entry);
            }
        }

        Collections.sort(results, new Comparator<ReadableMap>() {
            @Override
            public int compare(ReadableMap first, ReadableMap second) {
                return Double.compare(second.getDouble("confidence"), first.getDouble("confidence"));
            }
        });
        int finalSize = Math.min(results.size(), maxResultsResolved);
        WritableArray array = new WritableNativeArray();
        for (int i = 0; i < finalSize; i++) {
            array.pushMap(results.get(i));
        }

        inference.getTfContext().reset();
        return array;
    }

    private Bitmap loadImage(byte[] image) {
        BitmapFactory.Options options = new BitmapFactory.Options();
        options.inPreferredConfig = Bitmap.Config.ARGB_8888;
        return BitmapFactory.decodeByteArray(image, 0, image.length);
    }

    private Matrix createMatrix(int srcWidth, int srcHeight, int dstWidth, int dstHeight) {
        Matrix matrix = new Matrix();

        if (srcWidth != dstWidth || srcHeight != dstHeight) {
            float scaleFactorX = dstWidth / (float) srcWidth;
            float scaleFactorY = dstHeight / (float) srcHeight;
            float scaleFactor = Math.max(scaleFactorX, scaleFactorY);
            matrix.postScale(scaleFactor, scaleFactor);
        }

        matrix.invert(new Matrix());
        return matrix;
    }

}
