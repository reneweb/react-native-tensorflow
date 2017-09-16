package com.reactlibrary;

import android.util.Base64;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import org.tensorflow.Graph;
import org.tensorflow.Operation;

import java.util.HashMap;
import java.util.Map;

public class RNTensorflowGraphModule extends ReactContextBaseJavaModule {

    private ReactApplicationContext reactContext;
    private Map<String, Graph> graphs = new HashMap<>();

    public RNTensorflowGraphModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
    }

    @Override
    public String getName() {
        return "TensorflowGraph";
    }

    @Override
    public void onCatalystInstanceDestroy() {
        for (String id : graphs.keySet()) {
            close(id);
        }
    }

    public void init(String id, Graph graph) {
        graphs.put(id, graph);
    }

    public Operation getOperation(String id, String name) {
        Graph graph = graphs.get(id);
        if(graph != null) {
            return graph.operation(name);
        } else {
            return null;
        }
    }

    @ReactMethod
    public void importGraphDef(String id, String graphDef) {
        Graph graph = graphs.get(id);
        if(graph != null) {
            graph.importGraphDef(Base64.decode(graphDef, Base64.DEFAULT));
        }
    }

    @ReactMethod
    public void importGraphDef(String id, String graphDef, String prefix) {
        Graph graph = graphs.get(id);
        if(graph != null) {
            graph.importGraphDef(Base64.decode(graphDef, Base64.DEFAULT), prefix);
        }
    }

    @ReactMethod
    public void toGraphDef(String id, Promise promise) {
        try {
            Graph graph = graphs.get(id);
            promise.resolve(Base64.encodeToString(graph.toGraphDef(), Base64.DEFAULT));
        } catch (Exception e) {
            promise.resolve(e);
        }
    }

    @ReactMethod
    public void operation(String id, String name, Promise promise) {
        try {
            RNTensorflowGraphOperationsModule operationsModule =
                    reactContext.getNativeModule(RNTensorflowGraphOperationsModule.class);
            operationsModule.init();
            promise.resolve(true);
        } catch (Exception e) {
            promise.resolve(e);
        }
    }

    @ReactMethod
    public void close(String id) {
        Graph graph = graphs.get(id);
        if(graph != null) {
            graph.close();
        }
    }
}
