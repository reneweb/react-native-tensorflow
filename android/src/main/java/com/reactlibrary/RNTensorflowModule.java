
package com.reactlibrary;

import com.facebook.react.bridge.*;
import org.tensorflow.Graph;
import org.tensorflow.contrib.android.TensorFlowInferenceInterface;

import java.util.HashMap;
import java.util.Map;

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
  public void instantiateTensorflow(String id, String modelFilePath) {
    inferences.put(id, new TensorFlowInferenceInterface(reactContext.getAssets(), modelFilePath));
  }

  @ReactMethod
  public void feed(String id, String inputName, double[] src, long[] dims) {
    TensorFlowInferenceInterface inference = inferences.get(id);
    if(inference != null) {
      inference.feed(inputName, src, dims);
    }
  }

  @ReactMethod
  public void feed(String id, String inputName, double[] src) {
    TensorFlowInferenceInterface inference = inferences.get(id);
    if(inference != null) {
      inference.feed(inputName, src);
    }
  }

  @ReactMethod
  public void run(String id, String[] outputNames) {
    TensorFlowInferenceInterface inference = inferences.get(id);
    if(inference != null) {
      inference.run(outputNames);
    }
  }

  @ReactMethod
  public void run(String id, String[] outputNames, boolean enableStats) {
    TensorFlowInferenceInterface inference = inferences.get(id);
    if(inference != null) {
      inference.run(outputNames, enableStats);
    }
  }

  @ReactMethod
  public void fetch(String id, String outputName, int outputSize, Promise promise) {
    try {
      TensorFlowInferenceInterface inference = inferences.get(id);
      double[] dst = new double[outputSize];
      inference.fetch(outputName, dst);
      promise.resolve(dst);
    } catch (Exception e) {
      promise.reject(e);
    }
  }

  @ReactMethod
  public void graph(String id, Promise promise) {
    try {
      TensorFlowInferenceInterface inference = inferences.get(id);
      RNTensorflowGraphModule graphModule = reactContext.getNativeModule(RNTensorflowGraphModule.class);
      graphModule.init(inference.graph());
      promise.resolve(true);
    } catch (Exception e) {
      promise.reject(e);
    }
  }

  @ReactMethod
  public void graphOperation(String id, String operationName, Promise promise) {
    try {
      TensorFlowInferenceInterface inference = inferences.get(id);
      promise.resolve(inference.graphOperation(operationName));
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
