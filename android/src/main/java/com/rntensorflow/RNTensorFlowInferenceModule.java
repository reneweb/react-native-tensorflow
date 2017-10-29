
package com.rntensorflow;

import com.facebook.react.bridge.*;
import org.tensorflow.DataType;
import org.tensorflow.contrib.android.TensorFlowInferenceInterface;

import java.nio.FloatBuffer;
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

      TensorFlowInferenceInterface inference = inferences.get(id);
      RNTensorFlowGraphModule graphModule = reactContext.getNativeModule(RNTensorFlowGraphModule.class);
      graphModule.init(id, inference.graph());

      promise.resolve(true);
    } catch (Exception e) {
      promise.reject(e);
    }
  }

  @ReactMethod
  public void feed(String id, ReadableMap data, Promise promise) {
    try {
      String inputName = data.getString("name");
      long[] shape = data.hasKey("shape") ? readableArrayToLongArray(data.getArray("shape")) : new long[0];

      DataType dtype = data.hasKey("dtype")
              ? DataType.valueOf(data.getString("dtype").toUpperCase())
              : DataType.DOUBLE;

      TensorFlowInferenceInterface inference = inferences.get(id);
      if (inference != null) {
        if(dtype == DataType.DOUBLE) {
          double[] srcData = readableArrayToDoubleArray(data.getArray("data"));
          inference.feed(inputName, srcData, shape);
        } else if(dtype == DataType.FLOAT) {
          float[] srcData = readableArrayToFloatArray(data.getArray("data"));
          inference.feed(inputName, srcData, shape);
        } else if(dtype == DataType.INT32) {
          int[] srcData = readableArrayToIntArray(data.getArray("data"));
          inference.feed(inputName, srcData, shape);
        } else if(dtype == DataType.INT64) {
          double[] srcData = readableArrayToDoubleArray(data.getArray("data"));
          inference.feed(inputName, srcData, shape);
        } else if(dtype == DataType.UINT8) {
          int[] srcData = readableArrayToIntArray(data.getArray("data"));
          inference.feed(inputName, srcData, shape);
        } else if(dtype == DataType.BOOL) {
          byte[] srcData = readableArrayToByteBoolArray(data.getArray("data"));
          inference.feed(inputName, srcData, shape);
        } else if(dtype == DataType.STRING) {
          byte[] srcData = readableArrayToByteStringArray(data.getArray("data"));
          inference.feed(inputName, srcData, shape);
        }
        promise.resolve(true);
      } else {
        promise.reject(new IllegalStateException("Could not find inference for id"));
      }
    } catch (Exception e) {
      promise.reject(e);
    }
  }

  @ReactMethod
  public void run(String id, ReadableArray outputNames, boolean enableStats, Promise promise) {
    try {
      TensorFlowInferenceInterface inference = inferences.get(id);
      if(inference != null) {
        inference.run(readableArrayToStringArray(outputNames), enableStats);
        promise.resolve(true);
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
        promise.resolve(true);
      } else {
        promise.reject(new IllegalStateException("Could not find inference for id"));
      }
    } catch (Exception e) {
      promise.reject(e);
    }
  }
}
