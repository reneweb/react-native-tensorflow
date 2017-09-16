package com.reactlibrary;

import android.util.Base64;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import org.tensorflow.Graph;

public class RNTensorflowGraphModule extends ReactContextBaseJavaModule {

    private Graph graph;
    private ReactApplicationContext reactContext;

    public RNTensorflowGraphModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
    }

    @Override
    public String getName() {
        return "TensorflowGraph";
    }

    public void init(Graph graph) {
        this.graph = graph;
    }

    @ReactMethod
    public void importGraphDef(String graphDef) {
        this.graph.importGraphDef(Base64.decode(graphDef, Base64.DEFAULT));
    }

    @ReactMethod
    public void importGraphDef(String graphDef, String prefix) {
        this.graph.importGraphDef(Base64.decode(graphDef, Base64.DEFAULT), prefix);
    }

    @ReactMethod
    public void toGraphDef(Promise promise) {
        try {
            promise.resolve(Base64.encodeToString(this.graph.toGraphDef(), Base64.DEFAULT));
        } catch (Exception e) {
            promise.resolve(e);
        }
    }

    @ReactMethod
    public void operation(String name, Promise promise) {
        try {
            RNTensorflowGraphOperationsModule operationsModule =
                    reactContext.getNativeModule(RNTensorflowGraphOperationsModule.class);
            operationsModule.init(this.graph.operation(name));
            promise.resolve(true);
        } catch (Exception e) {
            promise.resolve(e);
        }
    }

    @ReactMethod
    public void close() {
        this.graph.close();
    }
}
