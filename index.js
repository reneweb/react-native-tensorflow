
import { NativeModules } from 'react-native';
import uuid from 'uuid/v1';

const { RNTensorflow, RNTensorflowGraph, RNTensorflowGraphOperations } = NativeModules;

class TensorflowOperation {
  constructor(id, opName) {
    this.id = id
    this.opName = opName
  }

  inputListLength(name) {
    return RNTensorflowGraphOperations.inputListLength(this.id, this.opName, name);
  }

  name() {
    return RNTensorflowGraphOperations.name(this.id, this.opName)
  }

  numOutputs() {
    return RNTensorflowGraphOperations.numOutputs(this.id, this.opName)
  }

  output(index) {
    return RNTensorflowGraphOperations.output(this.id, this.opName, index)
  }

  outputList(index, length) {
    return RNTensorflowGraphOperations.outputList(this.id, this.opName, index, length)
  }

  outputListLength(name) {
    return RNTensorflowGraphOperations.outputListLength(this.id, this.opName, name)
  }

  type() {
    return RNTensorflowGraphOperations.type(this.id, this.opName)
  }
}

class TensorflowGraph {
  constructor(id) {
    this.id = id
  }

  importGraphDef(graphDef) {
    RNTensorflowGraph.importGraphDef(this.id, graphDef)
  }

  importGraphDefWithPrefix(graphDef, prefix) {
    RNTensorflowGraph.importGraphDefWithPrefix(this.id, graphDef, prefix);
  }

  toGraphDef() {
    return RNTensorflowGraph.toGraphDef(this.id);
  }

  operation(name) {
    const resultPromise = RNTensorflowGraph.operation(this.id, name)
    return resultPromise.then(result => {
      if(result) {
        return new TensorflowOperation(this.id, name);
      } else {
        return Promise.reject(result)
      }
    })
  }

  close() {
    RNTensorflowGraph.close(this.id)
  }
}

class Tensorflow {

  static initWithModel(modelFileName, cb) {
    const tensorflow = new Tensorflow(modelFileName)
    cb(tensorflow)
    tensorflow.close()
  }

  constructor(modelFileName) {
    this.id = uuid()
    RNTensorflow.initTensorflow(this.id, modelFileName)
  }

  feedWithDims(inputName, src, dims) {
    RNTensorflow.feedWithDims(this.id, inputName, src, dims);
  }

  feed(inputName, src) {
    RNTensorflow.feed(this.id, inputName, src);
  }

  run(outputNames) {
    RNTensorflow.run(this.id, outputNames);
  }

  runWithStats(outputNames) {
    RNTensorflow.runWithStatsFlag(this.id, outputNames, true);
  }

  fetch(outputName, outputSize) {
    return RNTensorflow.fetch(this.id, outputName, dst);
  }

  graph() {
    const resultPromise = RNTensorflow.graph(this.id)
    return resultPromise.then(result => {
      if(result) {
        return new TensorflowGraph(this.id);
      } else {
        return Promise.reject(result)
      }
    })
  }

  stats() {
    return RNTensorflow.stats(this.id);
  }

  close() {
    RNTensorflow.close(this.id);
  }
}

export default Tensorflow;
