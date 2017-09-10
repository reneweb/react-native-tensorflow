
package com.reactlibrary;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
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
}