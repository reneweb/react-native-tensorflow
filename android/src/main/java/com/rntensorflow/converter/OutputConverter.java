package com.rntensorflow.converter;

import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableNativeMap;
import org.tensorflow.Output;

public class OutputConverter {

    public static WritableMap convert(Output output) {
        WritableNativeMap shapeMap = new WritableNativeMap();
        shapeMap.putInt("numDimensions", output.shape().numDimensions());

        WritableNativeMap map = new WritableNativeMap();
        map.putInt("index", output.index());
        map.putString("dataType", output.dataType().name());
        map.putMap("shape", shapeMap);

        return map;
    }
}
