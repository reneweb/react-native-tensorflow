
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

First you need to add the TensorFlow model to the project. There are a few ways to do that:

- Add as react native asset
Create the file `rn-cli.config.js` in the root of the project and add the following content in order for react native to bundle the model (ending with pb).
```
module.exports = {
  getAssetExts() {
    return ['pb']
  }
}
```
Then you can require the asset in the code, for example: `require('assets/tensorflow_inception_graph.pb')`

- Add as iOS / Android asset
Put the model in the android/src/main/assets folder for Android and for iOS put the model using XCode in the root of the project. In the code you can just reference the file path for the asset.

- Load from file system
Put the model file into the file system and reference using the file path.

- Fetch via url
Pass a url to fetch the model from a url. This won't store it locally, thus the next time the code is executed it will fetch it again.

After adding the model and creating a TensorFlow instance using the model you will need to feed your data as a array providing the input name, shape and data type.
Then run the inference and lastly fetch the result.

```javascript
import TensorFlow from 'react-native-tensorflow';

const tf = new TensorFlow('tensorflow_inception_graph.pb')
await tf.feed({name: "inputName", data: [1,2,3], shape:[1,2,4], dtype: "int64"})
await tf.run(['outputNames'])
const output = await tf.fetch('outputName')    
console.log(output)

```

Check the android TensorFlow example for more information on the API: https://github.com/tensorflow/tensorflow/blob/master/tensorflow/examples/android/src/org/tensorflow/demo/TensorFlowImageClassifier.java

### Supported data types
- DOUBLE
- FLOAT
- INT32
- INT64
- UINT8
- BOOL - On Android will be converted into a byte array
- STRING - On Android will be converted into a byte array


## Known issues
- Currently the data to feed to TensorFlow needs to be provided on the JS side and is then passed to the native side. Transferring large payloads this way is very inefficient and will likely have a negative performance impact. The same problem exists when loading large data, like images, from the native side into JS side for processing.
- The TensorFlow library itself as well as the TensorFlow models are quite large in size resulting in large builds.
