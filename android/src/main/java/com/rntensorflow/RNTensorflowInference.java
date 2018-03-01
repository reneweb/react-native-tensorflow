package com.rntensorflow;

import com.facebook.react.bridge.*;
import org.tensorflow.DataType;
import org.tensorflow.Graph;
import org.tensorflow.Session;
import org.tensorflow.Tensor;
import org.tensorflow.contrib.android.RunStats;

import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.DoubleBuffer;
import java.nio.FloatBuffer;
import java.nio.IntBuffer;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static com.rntensorflow.converter.ArrayConverter.*;
import static com.rntensorflow.converter.ArrayConverter.byteArrayToBoolReadableArray;
import static com.rntensorflow.converter.ArrayConverter.intArrayToReadableArray;

public class RNTensorflowInference {

    private final ReactContext reactContext;
    private final TfContext tfContext;

    public RNTensorflowInference(ReactContext reactContext, TfContext tfContext) {
        this.reactContext = reactContext;
        this.tfContext = tfContext;
    }

    public static RNTensorflowInference init(ReactContext reactContext, String model) throws IOException {
        loadNativeTf();
        TfContext context = createContext(reactContext, model);
        return new RNTensorflowInference(reactContext, context);
    }

    private static void loadNativeTf() {
        try {
            new RunStats();
        } catch (UnsatisfiedLinkError ule) {
            System.loadLibrary("tensorflow_inference");
        }
    }

    private static TfContext createContext(ReactContext reactContext, String model) throws IOException {
        byte[] b = new ResourceManager(reactContext).loadResource(model);

        Graph graph = new Graph();
        graph.importGraphDef(b);
        Session session = new Session(graph);
        Session.Runner runner = session.runner();

        return new TfContext(session, runner, graph);
    }

    public void feed(String inputName, Tensor tensor) {
        tfContext.runner.feed(inputName, tensor);
    }

    public void run(String[] outputNames, boolean enableStats) {
        if(tfContext != null) {
            for (String outputName : outputNames) {
                tfContext.runner.fetch(outputName);
            }
            List<Tensor> tensors = tfContext.runner.run();

            tfContext.outputTensors.clear();
            for (int i = 0; i < outputNames.length; i++) {
                tfContext.outputTensors.put(outputNames[i], tensors.get(i));
            }

        } else {
            throw new IllegalStateException("Could not find inference for id");
        }
    }

    public ReadableArray fetch(String outputName) {
            Tensor tensor = tfContext.outputTensors.get(outputName);
            int numElements = tensor.numElements();

            if(tensor.dataType() == DataType.DOUBLE) {
                DoubleBuffer dst = DoubleBuffer.allocate(numElements);
                tensor.writeTo(dst);
                return doubleArrayToReadableArray(dst.array());
            } else if(tensor.dataType() == DataType.FLOAT) {
                FloatBuffer dst = FloatBuffer.allocate(numElements);
                tensor.writeTo(dst);
                return floatArrayToReadableArray(dst.array());
            } else if(tensor.dataType() == DataType.INT32) {
                IntBuffer dst = IntBuffer.allocate(numElements);
                tensor.writeTo(dst);
                return intArrayToReadableArray(dst.array());
            } else if(tensor.dataType() == DataType.INT64) {
                DoubleBuffer dst = DoubleBuffer.allocate(numElements);
                tensor.writeTo(dst);
                return doubleArrayToReadableArray(dst.array());
            } else if(tensor.dataType() == DataType.UINT8) {
                IntBuffer dst = IntBuffer.allocate(numElements);
                tensor.writeTo(dst);
                return intArrayToReadableArray(dst.array());
            } else if(tensor.dataType() == DataType.BOOL) {
                ByteBuffer dst = ByteBuffer.allocate(numElements);
                tensor.writeTo(dst);
                return byteArrayToBoolReadableArray(dst.array());
            } else {
                throw new IllegalArgumentException("Data type is not supported");
            }
    }

    public void close() {
        if(tfContext != null) {
            tfContext.session.close();
            tfContext.outputTensors.clear();
        } else {
            throw new IllegalStateException("Could not find inference for id");
        }
    }

    public TfContext getTfContext() {
        return tfContext;
    }

    public static class TfContext {
        final Session session;
        Session.Runner runner;
        final Graph graph;
        private final Map<String, Tensor> outputTensors;

        TfContext(Session session, Session.Runner runner, Graph graph) {
            this.session = session;
            this.runner = runner;
            this.graph = graph;
            outputTensors = new HashMap<>();
        }

        public void reset() {
            runner = session.runner();
            outputTensors.clear();
        }
    }
}
