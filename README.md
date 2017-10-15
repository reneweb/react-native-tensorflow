
# react-native-tensorflow

A TensorFlow inference library for react native.
It follows the android inference api from TensorFlow: https://github.com/tensorflow/tensorflow/tree/master/tensorflow/contrib/android

~~This library is currently only supporting android~~

## Getting started

`$ npm install react-native-tensorflow --save`

### Mostly automatic installation

`$ react-native link react-native-tensorflow`

#### Additional steps for iOS

First you will need CocoaPods.

Create a Podfile in the iOS directory with the following content:
```
target '<ProjectName>'
       pod 'TensorFlow-experimental'
 ```

Then run `pod install`.

## Usage

First you need to put a model in the android/src/main/assets folder for Android
and for iOS put the model using XCode in the root of the project.
Then you can create an instance providing the file name of the model.
Next you will need to feed an image in the form of a number array.
Then run the inference and lastly fetch the result.

```javascript
import TensorFlow from 'react-native-tensorflow';

const tf = new TensorFlow('tensorflow_inception_graph.pb')
await tf.feed('inputName', [1,2,3,4,...])
await tf.run('outputNames')
const output = await tf.fetch('outputName', 10)    
console.log(output)

```

Check the android TensorFlow example for more information on the API: https://github.com/tensorflow/tensorflow/blob/master/tensorflow/examples/android/src/org/tensorflow/demo/TensorFlowImageClassifier.java
