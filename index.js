
import { NativeModules } from 'react-native';

const { RNTensorflow } = NativeModules;

class Tensorflow {

  static initWithModel(modelFileName, cb) {
    tensorflow = new Tensorflow(modelFileName)
    cb(tensorflow)
    tensorflow.close()
  }

  constructor(modelFileName) {
    super()
    RNTensorflow.initTensorflow(modelFileName)
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

  stats() {
    return RNTensorflow.stats();
  }

  close() {
    RNTensorflow.close();
  }
}

export default Tensorflow;
