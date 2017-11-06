
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
  private Map<String, TfContext> tfContexts = new HashMap<>();

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
    for (String id : tfContexts.keySet()) {
      TfContext tfContext = this.tfContexts.remove(id);
      if(tfContext != null) {
        tfContext.session.close();
      }
    }
  }

  @ReactMethod
  public void initTensorFlowInference(String id, String model, Promise promise) {
    try {
      loadNativeTf();
      TfContext context = createContext(model);
      tfContexts.put(id, context);

      RNTensorFlowGraphModule graphModule = reactContext.getNativeModule(RNTensorFlowGraphModule.class);
      graphModule.init(id, context.graph);

      promise.resolve(true);
    } catch (Exception e) {
      promise.reject(e);
    }
  }

  private void loadNativeTf() {
    try {
      new RunStats();
    } catch (UnsatisfiedLinkError ule) {
      System.loadLibrary("tensorflow_inference");
    }
  }

  private TfContext createContext(String model) throws IOException {
    InputStream inputStream = new ResourceManager(reactContext.getAssets()).loadResource(model);
    byte[] b = new byte[inputStream.available()];
    inputStream.read(b);

    Graph graph = new Graph();
    graph.importGraphDef(b);
    Session session = new Session(graph);
    Session.Runner runner = session.runner();

    return new TfContext(session, runner, graph);
  }

  @ReactMethod
  public void feed(String id, ReadableMap data, Promise promise) {
    try {
      String inputName = data.getString("name");
      long[] shape = data.hasKey("shape") ? readableArrayToLongArray(data.getArray("shape")) : new long[0];

      DataType dtype = data.hasKey("dtype")
              ? DataType.valueOf(data.getString("dtype").toUpperCase())
              : DataType.DOUBLE;

      TfContext tfContext = tfContexts.get(id);
      if (tfContext != null) {
        if(dtype == DataType.DOUBLE) {
          double[] srcData = readableArrayToDoubleArray(data.getArray("data"));
          tfContext.runner.feed(inputName, Tensor.create(shape, DoubleBuffer.wrap(srcData)));
        } else if(dtype == DataType.FLOAT) {
          float[] srcData = readableArrayToFloatArray(data.getArray("data"));
          tfContext.runner.feed(inputName, Tensor.create(shape, FloatBuffer.wrap(srcData)));
        } else if(dtype == DataType.INT32) {
          int[] srcData = readableArrayToIntArray(data.getArray("data"));
          tfContext.runner.feed(inputName, Tensor.create(shape, IntBuffer.wrap(srcData)));
        } else if(dtype == DataType.INT64) {
          double[] srcData = readableArrayToDoubleArray(data.getArray("data"));
          tfContext.runner.feed(inputName, Tensor.create(shape, DoubleBuffer.wrap(srcData)));
        } else if(dtype == DataType.UINT8) {
          int[] srcData = readableArrayToIntArray(data.getArray("data"));
          tfContext.runner.feed(inputName, Tensor.create(shape, IntBuffer.wrap(srcData)));
        } else if(dtype == DataType.BOOL) {
          byte[] srcData = readableArrayToByteBoolArray(data.getArray("data"));
          tfContext.runner.feed(inputName, Tensor.create(dtype, shape, ByteBuffer.wrap(srcData)));
        } else if(dtype == DataType.STRING) {
          byte[] srcData = readableArrayToByteStringArray(data.getArray("data"));
          tfContext.runner.feed(inputName, Tensor.create(dtype, shape, ByteBuffer.wrap(srcData)));
        }
        promise.resolve(true);
      } else {
        promise.reject(new IllegalStateException("Could not find tfContext for id"));
      }
    } catch (Exception e) {
      promise.reject(e);
    }
  }

  @ReactMethod
  public void run(String id, ReadableArray outputNames, boolean enableStats, Promise promise) {
    try {
      TfContext tfContext = tfContexts.get(id);
      if(tfContext != null) {
        String[] outputNamesString = readableArrayToStringArray(outputNames);
        for (String outputName : outputNamesString) {
          tfContext.runner.fetch(outputName);
        }
        List<Tensor> tensors = tfContext.runner.run();

        tfContext.outputTensors.clear();
        for (int i = 0; i < outputNamesString.length; i++) {
          tfContext.outputTensors.put(outputNamesString[i], tensors.get(i));
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
  public void fetch(String id, String outputName, Promise promise) {
    try {
      TfContext tfContext = tfContexts.get(id);

      Tensor tensor = tfContext.outputTensors.get(outputName);
      int numElements = tensor.numElements();
      DoubleBuffer dst = DoubleBuffer.allocate(numElements);
      tensor.writeTo(dst);

      promise.resolve(doubleArrayToReadableArray(dst.array()));
    } catch (Exception e) {
      promise.reject(e);
    }
  }

  @ReactMethod
  public void close(String id, Promise promise) {
    try {
      TfContext tfContext = this.tfContexts.remove(id);
      if(tfContext != null) {
        tfContext.session.close();
        tfContext.outputTensors.clear();
        promise.resolve(true);
      } else {
        promise.reject(new IllegalStateException("Could not find inference for id"));
      }
    } catch (Exception e) {
      promise.reject(e);
    }
  }

  private class TfContext {
    final Session session;
    final Session.Runner runner;
    final Graph graph;
    final Map<String, Tensor> outputTensors;

    TfContext(Session session, Session.Runner runner, Graph graph) {
      this.session = session;
      this.runner = runner;
      this.graph = graph;
      outputTensors = new HashMap<>();
    }
  }
}
