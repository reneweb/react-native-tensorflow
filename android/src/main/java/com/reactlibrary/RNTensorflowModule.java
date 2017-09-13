
package com.reactlibrary;

import com.facebook.react.bridge.*;
import org.tensorflow.contrib.android.TensorFlowInferenceInterface;

public class RNTensorflowModule extends ReactContextBaseJavaModule {

  private final ReactApplicationContext reactContext;
  private TensorFlowInferenceInterface inference;

  public RNTensorflowModule(ReactApplicationContext reactContext) {
    super(reactContext);
    this.reactContext = reactContext;
  }

  @Override
  public String getName() {
    return "RNTensorflow";
  }

  @ReactMethod
  public void instantiateTensorflow(String modelFilePath) {
    this.inference = new TensorFlowInferenceInterface(reactContext.getAssets(), modelFilePath);
  }

  @ReactMethod
  public void feed(String inputName, double[] src, long[] dims) {
    this.inference.feed(inputName, src, dims);
  }

  @ReactMethod
  public void feed(String inputName, double[] src) {
    this.inference.feed(inputName, src);
  }

  @ReactMethod
  public void run(String[] outputNames) {
    this.inference.run(outputNames);
  }

  @ReactMethod
  public void run(String[] outputNames, boolean enableStats) {
    this.inference.run(outputNames, enableStats);
  }

  @ReactMethod
  public void fetch(String outputName, int outputSize, Promise promise) {
    try {
      double[] dst = new double[outputSize];
      this.inference.fetch(outputName, dst);
      promise.resolve(dst);
    } catch (Exception e) {
      promise.reject(e);
    }
  }

  @ReactMethod
  public void graph(Promise promise) {
    try {
      promise.resolve(this.inference.graph());
    } catch (Exception e) {
      promise.reject(e);
    }
  }

  @ReactMethod
  public void graphOperation(String operationName, Promise promise) {
    try {
      promise.resolve(this.inference.graphOperation(operationName));
    } catch (Exception e) {
      promise.reject(e);
    }
  }

  @ReactMethod
  public void stats(Promise promise) {
    try {
      promise.resolve(this.inference.getStatString());
    } catch (Exception e) {
      promise.reject(e);
    }
  }

  @ReactMethod
  public void close() {
    this.inference.close();
  }
}
