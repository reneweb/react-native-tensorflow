package com.reactlibrary;

import com.facebook.react.bridge.*;
import org.tensorflow.Operation;
import org.tensorflow.Output;

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
    public void inputListLength(String name, Promise promise) {
        try {
            promise.resolve(graphOperation.inputListLength(name));
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
    public void output(int index, Promise promise) {
        try {
            promise.resolve(OutputConverter.convert(graphOperation.output(index)));
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void outputList(int index, int length, Promise promise) {
        try {
            Output[] outputs = graphOperation.outputList(index, length);
            WritableArray outputsConverted = new WritableNativeArray();
            for (Output output : outputs) {
                outputsConverted.pushMap(OutputConverter.convert(output));
            }
            promise.resolve(outputsConverted);
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void outputListLength(String name, Promise promise) {
        try {
            promise.resolve(graphOperation.outputListLength(name));
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
