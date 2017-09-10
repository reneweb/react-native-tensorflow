
package com.reactlibrary;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import org.tensorflow.Graph;
import org.tensorflow.Operation;
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

  }

  @ReactMethod
  public void feed(String inputName, double[] src) {

  }

  @ReactMethod
  public void run(String[] outputNames) {

  }

  @ReactMethod
  public void run(String[] outputNames, boolean enableStats) {

  }

  @ReactMethod
  public void fetch(String outputNames) {

  }

  @ReactMethod
  public Graph graph() {
    return this.inference.graph();
  }

  @ReactMethod
  public Operation graphOperation(String operationName) {
    return this.inference.graphOperation(operationName);
  }

  @ReactMethod
  public String stats() {
    return this.inference.getStatString();
  }

  @ReactMethod
  public void close() {
    this.inference.close();
  }
}