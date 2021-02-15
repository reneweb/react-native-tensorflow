
# react-native-tensorflow

**Note: This project is not maintained anymore**

A TensorFlow inference library for react native.
It follows the android inference api from TensorFlow: https://github.com/tensorflow/tensorflow/tree/master/tensorflow/contrib/android

## Getting started

`$ npm install react-native-tensorflow --save`

### Linking

`$ react-native link react-native-tensorflow`

#### Additional steps for iOS

For the iOS setup you will need CocoaPods.

Create a Podfile in the iOS directory with the following content:
```
target '<ProjectName>'
       pod 'TensorFlow-experimental'
 ```

Then run `pod install`.

## Usage

This library provides a api to directly interact with TensorFlow and a simple image recognition api.
For most use cases for image recognition the image recognition api should suffice.

### Image recognition

First you need to add the TensorFlow model as well as the label file to the project. There are a few ways to do that as described [here](#fetching-files)

Next you need to initialize the TfImageRecognition class using the model and label files and then call the `recognize` function of the class with the image to recognize:

```javascript
import { TfImageRecognition } from 'react-native-tensorflow';

const tfImageRecognition = new TfImageRecognition({
  model: require('./assets/tensorflow_inception_graph.pb'),
  labels: require('./assets/tensorflow_labels.txt'),
  imageMean: 117, // Optional, defaults to 117
  imageStd: 1 // Optional, defaults to 1
})

const results = await tfImageRecognition.recognize({
  image: require('./assets/apple.jpg'),
  inputName: "input", //Optional, defaults to "input"
  inputSize: 224, //Optional, defaults to 224
  outputName: "output", //Optional, defaults to "output"
  maxResults: 3, //Optional, defaults to 3
  threshold: 0.1, //Optional, defaults to 0.1
})

results.forEach(result =>
  console.log(
    result.id, // Id of the result
    result.name, // Name of the result
    result.confidence // Confidence value between 0 - 1
  )
)

await tfImageRecognition.close() // Necessary in order to release objects on native side
```

### Direct API
*Note: It is not recommended to use this API as it has some major problem described in [the second point in the known issues](https://github.com/reneweb/react-native-tensorflow/blob/master/README.md#known-issues) and is quite difficult to use in its current state.*

First you need to add the TensorFlow model to the project. There are a few ways to do that as described [here](#fetching-files)

After adding the model and creating a TensorFlow instance using the model you will need to feed your data as a array providing the input name, shape and data type.
Then run the inference and lastly fetch the result.

```javascript
import { TensorFlow } from 'react-native-tensorflow';

const tf = new TensorFlow('tensorflow_inception_graph.pb')
await tf.feed({name: "inputName", data: [1,2,3], shape:[1,2,4], dtype: "int64"})
await tf.run(['outputNames'])
const output = await tf.fetch('outputName')    
console.log(output)

```

Check the android TensorFlow example for more information on the API: https://github.com/tensorflow/tensorflow/blob/master/tensorflow/examples/android/src/org/tensorflow/demo/TensorFlowImageClassifier.java

### Fetching files

- Add as react native asset

Create the file `rn-cli.config.js` in the root of the project and add the following code where the array contains all the file endings you want to bundle (in this case we bundle pb and txt  files next to the defaults).
```
module.exports = {
  getAssetExts() {
    return ['pb', 'txt']
  }
}
```
Then you can require the asset in the code, for example: `require('assets/tensorflow_inception_graph.pb')`

- Add as iOS / Android asset

Put the file in the android/src/main/assets folder for Android and for iOS put the file, using XCode, in the root of the project. In the code you can just reference the file path for the asset.

- Load from file system

Put the file into the file system and reference using the file path.

- Fetch via url

Pass a url to fetch the file from a url. This won't store it locally, thus the next time the code is executed it will fetch it again.

## Supported data types
- DOUBLE
- FLOAT
- INT32
- INT64
- UINT8
- BOOL - On Android will be converted into a byte array
- STRING - On Android will be converted into a byte array

## Known issues
- When using the image recognition api the results don't match exactly between Android and iOS. Most of the time they seem reasonable close though.
- When using the direct api the data to feed to TensorFlow needs to be provided on the JS side and is then passed to the native side. Transferring large payloads this way is very inefficient and will likely have a negative performance impact. The same problem exists when loading large data, like images, from the native side into JS side for processing.
- The TensorFlow library itself as well as the TensorFlow models are quite large in size resulting in large builds.
