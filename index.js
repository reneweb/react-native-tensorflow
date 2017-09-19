
import { NativeModules } from 'react-native';
import uuid from 'uuid/v1';

const { RNTensorFlowInference, RNTensorFlowGraph, RNTensorFlowGraphOperations } = NativeModules;

class TensorFlowOperation {
  constructor(id, opName) {
    this.id = id
    this.opName = opName
  }

  inputListLength(name) {
    return RNTensorFlowGraphOperations.inputListLength(this.id, this.opName, name);
  }

  name() {
    return RNTensorFlowGraphOperations.name(this.id, this.opName)
  }

  numOutputs() {
    return RNTensorFlowGraphOperations.numOutputs(this.id, this.opName)
  }

  output(index) {
    return RNTensorFlowGraphOperations.output(this.id, this.opName, index)
  }

  outputList(index, length) {
    return RNTensorFlowGraphOperations.outputList(this.id, this.opName, index, length)
  }

  outputListLength(name) {
    return RNTensorFlowGraphOperations.outputListLength(this.id, this.opName, name)
  }

  type() {
    return RNTensorFlowGraphOperations.type(this.id, this.opName)
  }
}

class TensorFlowGraph {
  constructor(id) {
    this.id = id
  }

  importGraphDef(graphDef) {
    RNTensorFlowGraph.importGraphDef(this.id, graphDef)
  }

  importGraphDefWithPrefix(graphDef, prefix) {
    RNTensorFlowGraph.importGraphDefWithPrefix(this.id, graphDef, prefix);
  }

  toGraphDef() {
    return RNTensorFlowGraph.toGraphDef(this.id);
  }

  operation(name) {
    const resultPromise = RNTensorFlowGraph.operation(this.id, name)
    return resultPromise.then(result => {
      if(result) {
        return new TensorFlowOperation(this.id, name);
      } else {
        return Promise.reject(result)
      }
    })
  }

  close() {
    RNTensorFlowGraph.close(this.id)
  }
}

class TensorFlowInference {

  constructor(modelFileName) {
    this.id = uuid()
    RNTensorFlowInference.initTensorFlowInference(this.id, modelFileName)
  }

  feedWithDims(inputName, src, dims) {
    RNTensorFlowInference.feedWithDims(this.id, inputName, src, dims);
  }

  feed(inputName, src) {
    RNTensorFlowInference.feed(this.id, inputName, src);
  }

  run(outputNames) {
    RNTensorFlowInference.run(this.id, outputNames);
  }

  runWithStats(outputNames) {
    RNTensorFlowInference.runWithStatsFlag(this.id, outputNames, true);
  }

  fetch(outputName, outputSize) {
    return RNTensorFlowInference.fetch(this.id, outputName, outputSize);
  }

  graph() {
    const resultPromise = RNTensorFlowInference.graph(this.id)
    return resultPromise.then(result => {
      if(result) {
        return new TensorFlowGraph(this.id);
      } else {
        return Promise.reject(result)
      }
    })
  }

  stats() {
    return RNTensorFlowInference.stats(this.id);
  }

  close() {
    RNTensorFlowInference.close(this.id);
  }
}

export default TensorFlowInference;
