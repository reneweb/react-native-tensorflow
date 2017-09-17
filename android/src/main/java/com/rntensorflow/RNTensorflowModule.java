
package com.rntensorflow;

import com.facebook.react.bridge.*;
import com.rntensorflow.converter.ArrayConverter;
import org.tensorflow.contrib.android.TensorFlowInferenceInterface;

import java.util.HashMap;
import java.util.Map;

import static com.rntensorflow.converter.ArrayConverter.*;

public class RNTensorflowModule extends ReactContextBaseJavaModule {

  private final ReactApplicationContext reactContext;
  private Map<String, TensorFlowInferenceInterface> inferences = new HashMap<>();

  public RNTensorflowModule(ReactApplicationContext reactContext) {
    super(reactContext);
    this.reactContext = reactContext;
  }

  @Override
  public String getName() {
    return "RNTensorflow";
  }

  @Override
  public void onCatalystInstanceDestroy() {
    for (String id : inferences.keySet()) {
      this.close(id);
    }
  }

  @ReactMethod
  public void initTensorflow(String id, String modelFilePath) {
    inferences.put(id, new TensorFlowInferenceInterface(reactContext.getAssets(), modelFilePath));
  }

  @ReactMethod
  public void feedWithDims(String id, String inputName, ReadableArray src, ReadableArray dims) {
    TensorFlowInferenceInterface inference = inferences.get(id);
    if(inference != null) {
      inference.feed(inputName, readableArrayToDoubleArray(src), readableArrayToLongArray(dims));
    }
  }

  @ReactMethod
  public void feed(String id, String inputName, ReadableArray src) {
    TensorFlowInferenceInterface inference = inferences.get(id);
    if(inference != null) {
      inference.feed(inputName, readableArrayToDoubleArray(src));
    }
  }

  @ReactMethod
  public void run(String id, ReadableArray outputNames) {
    TensorFlowInferenceInterface inference = inferences.get(id);
    if(inference != null) {
      inference.run(readableArrayToStringArray(outputNames));
    }
  }

  @ReactMethod
  public void runWithStatsFlag(String id, ReadableArray outputNames, boolean enableStats) {
    TensorFlowInferenceInterface inference = inferences.get(id);
    if(inference != null) {
      inference.run(readableArrayToStringArray(outputNames), enableStats);
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
      RNTensorflowGraphModule graphModule = reactContext.getNativeModule(RNTensorflowGraphModule.class);
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
  public void close(String id) {
    TensorFlowInferenceInterface inference = this.inferences.remove(id);
    if(inference != null) {
      inference.close();
    }
  }
}
