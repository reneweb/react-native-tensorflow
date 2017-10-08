
package com.rntensorflow;

import com.facebook.react.bridge.*;
import org.tensorflow.contrib.android.TensorFlowInferenceInterface;

import java.util.HashMap;
import java.util.Map;

import static com.rntensorflow.converter.ArrayConverter.*;

public class RNTensorFlowInferenceModule extends ReactContextBaseJavaModule {

  private final ReactApplicationContext reactContext;
  private Map<String, TensorFlowInferenceInterface> inferences = new HashMap<>();

  public RNTensorFlowInferenceModule(ReactApplicationContext reactContext) {
    super(reactContext);
    this.reactContext = reactContext;
  }

  @Override
  public String getName() {
    return "RNTensorFlowInference";
  }

  @Override
  public void onCatalystInstanceDestroy() {
    for (String id : inferences.keySet()) {
      TensorFlowInferenceInterface inference = this.inferences.remove(id);
      if(inference != null) {
        inference.close();
      }
    }
  }

  @ReactMethod
  public void initTensorFlowInference(String id, String modelFilePath, Promise promise) {
    try {
      inferences.put(id, new TensorFlowInferenceInterface(reactContext.getAssets(), modelFilePath));
      promise.resolve(true);
    } catch (Exception e) {
      promise.reject(e);
    }
  }

  @ReactMethod
  public void feedWithDims(String id, String inputName, ReadableArray src, ReadableArray dims, Promise promise) {
    try {
      TensorFlowInferenceInterface inference = inferences.get(id);
      if (inference != null) {
        inference.feed(inputName, readableArrayToDoubleArray(src), readableArrayToLongArray(dims));
      } else {
        promise.reject(new IllegalStateException("Could not find inference for id"));
      }
    } catch (Exception e) {
      promise.reject(e);
    }
  }

  @ReactMethod
  public void feed(String id, String inputName, ReadableArray src, Promise promise) {
    feedWithDims(id, inputName, src, new WritableNativeArray(), promise);
  }

  @ReactMethod
  public void run(String id, ReadableArray outputNames, Promise promise) {
    runWithStatsFlag(id, outputNames, false, promise);
  }

  @ReactMethod
  public void runWithStatsFlag(String id, ReadableArray outputNames, boolean enableStats, Promise promise) {
    try {
      TensorFlowInferenceInterface inference = inferences.get(id);
      if(inference != null) {
        inference.run(readableArrayToStringArray(outputNames), enableStats);
      } else {
        promise.reject(new IllegalStateException("Could not find inference for id"));
      }
    } catch (Exception e) {
      promise.reject(e);
    }
  }

  @ReactMethod
  public void fetch(String id, String outputName, int outputSize, Promise promise) {
    try {
      TensorFlowInferenceInterface inference = inferences.get(id);
      double[] dst = new double[outputSize];
      inference.fetch(outputName, dst);
      promise.resolve(doubleArrayToReadableArray(dst));
    } catch (Exception e) {
      promise.reject(e);
    }
  }

  @ReactMethod
  public void graph(String id, Promise promise) {
    try {
      TensorFlowInferenceInterface inference = inferences.get(id);
      RNTensorFlowGraphModule graphModule = reactContext.getNativeModule(RNTensorFlowGraphModule.class);
      graphModule.init(id, inference.graph());
      promise.resolve(true);
    } catch (Exception e) {
      promise.reject(e);
    }
  }

  @ReactMethod
  public void stats(String id, Promise promise) {
    try {
      TensorFlowInferenceInterface inference = inferences.get(id);
      promise.resolve(inference.getStatString());
    } catch (Exception e) {
      promise.reject(e);
    }
  }

  @ReactMethod
  public void close(String id, Promise promise) {
    try {
      TensorFlowInferenceInterface inference = this.inferences.remove(id);
      if(inference != null) {
        inference.close();
      } else {
        promise.reject(new IllegalStateException("Could not find inference for id"));
      }
    } catch (Exception e) {
      promise.reject(e);
    }
  }
}
