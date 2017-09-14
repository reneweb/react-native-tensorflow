package com.reactlibrary;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import org.tensorflow.Graph;

public class RNTensorflowGraphModule extends ReactContextBaseJavaModule {

    private Graph graph;

    public RNTensorflowGraphModule(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @Override
    public String getName() {
        return "TensorflowGraph";
    }

    @ReactMethod
    public void init(Graph graph) {
        this.graph = graph;
    }

    @ReactMethod
    public void importGraphDef(byte[] graphDef) {
        this.graph.importGraphDef(graphDef);
    }

    @ReactMethod
    public void importGraphDef(byte[] graphDef, String prefix) {
        this.graph.importGraphDef(graphDef, prefix);
    }

    @ReactMethod
    public void toGraphDef(Promise promise) {
        try {
            promise.resolve(this.graph.toGraphDef());
        } catch (Exception e) {
            promise.resolve(e);
        }
    }

    @ReactMethod
    public void operation(String name, Promise promise) {
        try {
            promise.resolve(this.graph.operation(name));
        } catch (Exception e) {
            promise.resolve(e);
        }
    }

    @ReactMethod
    public void close(Graph graph) {
        this.graph.close();
    }
}
