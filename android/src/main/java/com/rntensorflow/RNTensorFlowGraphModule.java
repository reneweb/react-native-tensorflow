package com.rntensorflow;

import android.util.Base64;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import org.tensorflow.Graph;
import org.tensorflow.Operation;

import java.util.HashMap;
import java.util.Map;

public class RNTensorFlowGraphModule extends ReactContextBaseJavaModule {

    private ReactApplicationContext reactContext;
    private Map<String, Graph> graphs = new HashMap<>();

    public RNTensorFlowGraphModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
    }

    @Override
    public String getName() {
        return "RNTensorFlowGraph";
    }

    @Override
    public void onCatalystInstanceDestroy() {
        for (String key : graphs.keySet()) {
            graphs.get(key).close();
        }
    }

    public void init(String id, Graph graph) {
        graphs.put(id, graph);
    }

    public Operation getOperation(String id, String name) {
        Graph graph = graphs.get(id);
        if(graph != null && name != null) {
            return graph.operation(name);
        } else {
            return null;
        }
    }

    @ReactMethod
    public void importGraphDef(String id, String graphDef, Promise promise) {
        importGraphDefWithPrefix(id, graphDef, "", promise);
    }

    @ReactMethod
    public void importGraphDefWithPrefix(String id, String graphDef, String prefix, Promise promise) {
        try {
            Graph graph = graphs.get(id);
            graph.importGraphDef(Base64.decode(graphDef, Base64.DEFAULT), prefix);
            promise.resolve(true);
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void toGraphDef(String id, Promise promise) {
        try {
            Graph graph = graphs.get(id);
            promise.resolve(Base64.encodeToString(graph.toGraphDef(), Base64.DEFAULT));
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void close(String id, Promise promise) {
        try {
            Graph graph = graphs.get(id);
            graph.close();
            promise.resolve(true);
        } catch (Exception e) {
            promise.reject(e);
        }
    }
}
