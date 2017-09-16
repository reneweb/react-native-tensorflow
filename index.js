
import { NativeModules } from 'react-native';
import uuid from 'react-native-uuid';

const { RNTensorflow } = NativeModules;

class Tensorflow {

  static initWithModel(modelFileName, cb) {
    tensorflow = new Tensorflow(modelFileName)
    cb(tensorflow)
    tensorflow.close()
  }

  constructor(modelFileName) {
    super()
    this.id = uuid.v1()
    RNTensorflow.initTensorflow(modelFileName)
  }

  feedWithDims(inputName, src, dims) {
    RNTensorflow.feed(this.id, inputName, src, dims);
  }

  feed(inputName, src) {
    RNTensorflow.feed(this.id, inputName, src);
  }

  run(outputNames) {
    RNTensorflow.run(this.id, outputNames);
  }

  runWithStats(outputNames) {
    RNTensorflow.run(this.id, outputNames, true);
  }

  fetch(outputName, outputSize) {
    return RNTensorflow.fetch(this.id, outputName, dst);
  }

  graph() {
    return RNTensorflow.graph(this.id);
  }

  stats() {
    return RNTensorflow.stats(this.id);
  }

  close() {
    RNTensorflow.close(this.id);
  }
}

export default Tensorflow;
