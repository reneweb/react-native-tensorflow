package com.rntensorflow;

import com.facebook.react.bridge.*;
import com.rntensorflow.converter.OutputConverter;
import org.tensorflow.Operation;
import org.tensorflow.Output;

public class RNTensorFlowGraphOperationsModule extends ReactContextBaseJavaModule {

    public RNTensorFlowGraphOperationsModule(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @Override
    public String getName() {
        return "RNTensorFlowGraphOperations";
    }

    @ReactMethod
    public void inputListLength(String id, String opName, String name, Promise promise) {
        try {
            Operation graphOperation = getGraphOperation(id, opName);
            promise.resolve(graphOperation.inputListLength(name));
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void name(String id, String opName, Promise promise) {
        try {
            Operation graphOperation = getGraphOperation(id, opName);
            promise.resolve(graphOperation.name());
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void numOutputs(String id, String opName, Promise promise) {
        try {
            Operation graphOperation = getGraphOperation(id, opName);
            promise.resolve(graphOperation.numOutputs());
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void output(String id, String opName, int index, Promise promise) {
        try {
            Operation graphOperation = getGraphOperation(id, opName);
            promise.resolve(OutputConverter.convert(graphOperation.output(index)));
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void outputList(String id, String opName, int index, int length, Promise promise) {
        try {
            Operation graphOperation = getGraphOperation(id, opName);
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
    public void outputListLength(String id, String opName, String name, Promise promise) {
        try {
            Operation graphOperation = getGraphOperation(id, opName);
            promise.resolve(graphOperation.outputListLength(name));
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void type(String id, String opName, Promise promise) {
        try {
            Operation graphOperation = getGraphOperation(id, opName);
            promise.resolve(graphOperation.type());
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    private Operation getGraphOperation(String id, String name) {
        return getReactApplicationContext().getNativeModule(RNTensorFlowGraphModule.class).getOperation(id, name);
    }
}
