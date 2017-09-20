
# react-native-tensorflow

A TensorFlow inference library for react native.
It follows the android inference api from TensorFlow: https://github.com/tensorflow/tensorflow/tree/master/tensorflow/contrib/android

_This library is currently only supporting android_

## Getting started

`$ npm install react-native-tensorflow --save`

### Mostly automatic installation

`$ react-native link react-native-tensorflow`

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-tensorflow` and add `RNTensorflow.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNTensorflow.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import com.rntensorflow.RNTensorFlowPackage;` to the imports at the top of the file
  - Add `new RNTensorFlowPackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-tensorflow'
  	project(':react-native-tensorflow').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-tensorflow/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-tensorflow')
  	```

## Usage

First you need to put a model in the android/src/main/assets folder.
Then you can create an instance providing the file name of the model.
Next you will need to feed an image in the form of a number array.
Then run the inference and lastly fetch the result.

```javascript
import TensorFlowInference from 'react-native-tensorflow';


const tensorflowInference = new TensorFlowInference('tensorflow_inception_graph.pb')
tensorflowInference.feed('inputName', [1,2,3,4,...])
tensorflowInference.run('outputNames')
tensorflowInference.fetch('outputName', 10).then(output => console.log(output))
```

Check the android TensorFlow example for more information on the API: https://github.com/tensorflow/tensorflow/blob/master/tensorflow/examples/android/src/org/tensorflow/demo/TensorFlowImageClassifier.java
