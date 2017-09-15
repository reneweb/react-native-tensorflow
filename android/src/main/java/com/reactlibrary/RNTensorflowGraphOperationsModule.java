package com.reactlibrary;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import org.tensorflow.Operation;

public class RNTensorflowGraphOperationsModule extends ReactContextBaseJavaModule {

    private Operation graphOperation;

    public RNTensorflowGraphOperationsModule(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @Override
    public String getName() {
        return "TensorflorGraphOperation";
    }

    @ReactMethod
    public void init(Operation graphOperation) {
        this.graphOperation = graphOperation;
    }

    @ReactMethod
    public void inputListLength(String s, Promise promise) {
        try {
            promise.resolve(graphOperation.inputListLength(s));
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void name(Promise promise) {
        try {
            promise.resolve(graphOperation.name());
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void numOutputs(Promise promise) {
        try {
            promise.resolve(graphOperation.numOutputs());
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void output(int output, Promise promise) {
        try {
            promise.resolve(graphOperation.output(output));
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void outputList(int i, int ii, Promise promise) {
        try {
            promise.resolve(graphOperation.outputList(i, ii));
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void outputListLength(String s, Promise promise) {
        try {
            promise.resolve(graphOperation.outputListLength(s));
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void type(Promise promise) {
        try {
            promise.resolve(graphOperation.type());
        } catch (Exception e) {
            promise.reject(e);
        }
    }
}
