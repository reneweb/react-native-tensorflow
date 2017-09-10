
import { NativeModules } from 'react-native';

const { RNTensorflow } = NativeModules;

class Tensorflow {

  setupForModel(modelFileName) {
    RNTensorflow.instantiateTensorflow(modelFileName)
  }

  feedWithDims(inputName, src, dims) {
    RNTensorflow.feed(inputName, src, dims);
  }

  feed(inputName, src) {
    RNTensorflow.feed(inputName, src);
  }

  run(outputNames) {
    RNTensorflow.run(outputNames);
  }

  runWithStats(outputNames) {
    RNTensorflow.run(outputNames, true);
  }

  fetch(outputName, outputSize) {
    return RNTensorflow.fetch(outputName, dst);
  }

  graph() {
    return RNTensorflow.graph();
  }

  graphOperation(operationName) {
    return RNTensorflow.graphOperation(operationName);
  }

  stats() {
    return RNTensorflow.getStatString();
  }

  close() {
    RNTensorflow.close();
  }
}

export default new Tensorflow();
