package com.rntensorflow.imagerecognition;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;

import java.util.HashMap;
import java.util.Map;

public class RNImageRecognizerModule extends ReactContextBaseJavaModule {

    private Map<String, ImageRecognizer> imageRecognizers = new HashMap<>();
    private ReactApplicationContext reactContext;

    public RNImageRecognizerModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
    }

    @Override
    public String getName() {
        return "RNImageRecognition";
    }

    @Override
    public void onCatalystInstanceDestroy() {
        for (String id : imageRecognizers.keySet()) {
            this.imageRecognizers.remove(id);
        }
    }

    @ReactMethod
    public void initImageRecognizer(String id, ReadableMap data, Promise promise) {
        try {
            String model = data.getString("model");
            String label = data.getString("label");
            Integer imageMean = data.hasKey("imageMean") ? data.getInt("imageMean") : null;
            Double imageStd = data.hasKey("imageStd") ? data.getDouble("imageStd") : null;

            ImageRecognizer imageRecognizer = ImageRecognizer.init(reactContext, model, label, imageMean, imageStd);
            imageRecognizers.put(id, imageRecognizer);
            promise.resolve(true);
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void recognize(String id, ReadableMap data, Promise promise) {
        try {
            String image = data.getString("image");
            String inputName = data.getString("inputName");
            Integer inputSize = data.hasKey("inputSize") ? data.getInt("inputSize") : null;
            String outputName = data.getString("outputName");
            Integer maxResults = data.hasKey("maxResults") ? data.getInt("maxResults") : null;
            Double threshold = data.hasKey("threshold") ? data.getDouble("threshold") : null;

            ImageRecognizer imageRecognizer = imageRecognizers.get(id);
            imageRecognizer.recognizeImage(image, inputName, inputSize, outputName, maxResults, threshold);
            promise.resolve(true);
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void close(String id, Promise promise) {
        try {
            this.imageRecognizers.remove(id);
            promise.resolve(true);
        } catch (Exception e) {
            promise.reject(e);
        }
    }
}
