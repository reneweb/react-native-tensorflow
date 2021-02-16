
package com.rntensorflow;

import com.facebook.react.bridge.*;
import org.tensorflow.DataType;
import org.tensorflow.Graph;
import org.tensorflow.Session;
import org.tensorflow.Tensor;
import org.tensorflow.contrib.android.RunStats;

import java.io.IOException;
import java.io.InputStream;
import java.nio.ByteBuffer;
import java.nio.DoubleBuffer;
import java.nio.FloatBuffer;
import java.nio.IntBuffer;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static com.rntensorflow.converter.ArrayConverter.*;

public class RNTensorFlowInferenceModule extends ReactContextBaseJavaModule {

  private final ReactApplicationContext reactContext;
  private Map<String, RNTensorflowInference> inferenceMap = new HashMap<>();

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
    for (String id : inferenceMap.keySet()) {
      RNTensorflowInference inference = this.inferenceMap.remove(id);
      if(inference != null) {
        inference.close();
      }
    }
  }

  @ReactMethod
  public void initTensorFlowInference(String id, String model, Promise promise) {
    try {
      RNTensorflowInference inference = RNTensorflowInference.init(reactContext, model);
      inferenceMap.put(id, inference);

      RNTensorFlowGraphModule graphModule = reactContext.getNativeModule(RNTensorFlowGraphModule.class);
      graphModule.init(id, inference.getTfContext().graph);

      promise.resolve(true);
    } catch (Exception e) {
      promise.reject(e);
    }
  }

  @ReactMethod
  public void feed(String id, ReadableMap data, Promise promise) {
    try {
      RNTensorflowInference inference = inferenceMap.get(id);

      String inputName = data.getString("name");
      long[] shape = data.hasKey("shape") ? readableArrayToLongArray(data.getArray("shape")) : new long[0];

      DataType dtype = data.hasKey("dtype")
              ? DataType.valueOf(data.getString("dtype").toUpperCase())
              : DataType.DOUBLE;

      if(dtype == DataType.DOUBLE) {
        double[] srcData = readableArrayToDoubleArray(data.getArray("data"));
        inference.feed(inputName, Tensor.create(shape, DoubleBuffer.wrap(srcData)));
      } else if(dtype == DataType.FLOAT) {
        float[] srcData = readableArrayToFloatArray(data.getArray("data"));
        inference.feed(inputName, Tensor.create(shape, FloatBuffer.wrap(srcData)));
      } else if(dtype == DataType.INT32) {
        int[] srcData = readableArrayToIntArray(data.getArray("data"));
        inference.feed(inputName, Tensor.create(shape, IntBuffer.wrap(srcData)));
      } else if(dtype == DataType.INT64) {
        double[] srcData = readableArrayToDoubleArray(data.getArray("data"));
        inference.feed(inputName, Tensor.create(shape, DoubleBuffer.wrap(srcData)));
      } else if(dtype == DataType.UINT8) {
        int[] srcData = readableArrayToIntArray(data.getArray("data"));
        inference.feed(inputName, Tensor.create(shape, IntBuffer.wrap(srcData)));
      } else if(dtype == DataType.BOOL) {
        byte[] srcData = readableArrayToByteBoolArray(data.getArray("data"));
        inference.feed(inputName, Tensor.create(Boolean.class, shape, ByteBuffer.wrap(srcData)));
      } else if(dtype == DataType.STRING) {
        byte[] srcData = readableArrayToByteStringArray(data.getArray("data"));
        inference.feed(inputName, Tensor.create(String.class, shape, ByteBuffer.wrap(srcData)));
      } else {
        promise.reject(new IllegalArgumentException("Data type is not supported"));
        return;
      }
      promise.resolve(true);
    } catch (Exception e) {
      promise.reject(e);
    }
  }

  @ReactMethod
  public void run(String id, ReadableArray outputNames, boolean enableStats, Promise promise) {
    try {
      RNTensorflowInference inference = inferenceMap.get(id);
      inference.run(readableArrayToStringArray(outputNames), enableStats);
      promise.resolve(true);
    } catch (Exception e) {
      promise.reject(e);
    }
  }

  @ReactMethod
  public void fetch(String id, String outputName, Promise promise) {
    try {
      RNTensorflowInference inference = inferenceMap.get(id);
      promise.resolve(inference.fetch(outputName));
    } catch (Exception e) {
      promise.reject(e);
    }
  }

  @ReactMethod
  public void reset(String id, Promise promise) {
    try {
      RNTensorflowInference inference = inferenceMap.get(id);
      inference.getTfContext().reset();
      promise.resolve(true);
    } catch (Exception e) {
      promise.reject(e);
    }
  }

  @ReactMethod
  public void close(String id, Promise promise) {
    try {
      RNTensorflowInference inference = inferenceMap.get(id);
      inference.close();
      promise.resolve(true);
    } catch (Exception e) {
      promise.reject(e);
    }
  }
}
