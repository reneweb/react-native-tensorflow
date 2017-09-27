#import "RNTensorFlowInference.h"

@implementation RNTensorFlowInference

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(initTensorFlowInference:(NSString *)id modelFilePath:(NSString *)modelFilePath)
{
    //inferences.put(id, new TensorFlowInferenceInterface(reactContext.getAssets(), modelFilePath));
}

RCT_EXPORT_METHOD(feedWithDims:(NSString *)id inputName:(NSString *)inputName src:(NSArray *)src dims:(NSArray *)dims)
{
    //TensorFlowInferenceInterface inference = inferences.get(id);
    //if(inference != null) {
    //    inference.feed(inputName, readableArrayToDoubleArray(src), readableArrayToLongArray(dims));
    //}
}

RCT_EXPORT_METHOD(feed:(NSString *)id inputName:(NSString *)inputName src:(NSArray *)src)
{
    //TensorFlowInferenceInterface inference = inferences.get(id);
    //if(inference != null) {
    //    inference.feed(inputName, readableArrayToDoubleArray(src));
    //}
}

RCT_EXPORT_METHOD(run:(NSString *)id outputNames:(NSArray *)outputNames)
{
    //TensorFlowInferenceInterface inference = inferences.get(id);
    //if(inference != null) {
    //    inference.run(readableArrayToStringArray(outputNames));
    //}
}

RCT_EXPORT_METHOD(runWithStatsFlag:(NSString *)id outputNames:(NSArray *)outputNames enableStats:(bool)enableStats)
{
    //TensorFlowInferenceInterface inference = inferences.get(id);
    //if(inference != null) {
    //    inference.run(readableArrayToStringArray(outputNames), enableStats);
    //}
}

RCT_EXPORT_METHOD(fetch:(NSString *)id outputName:(NSString *)outputName outputSize:(NSInteger *)outputSize resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    //try {
    //    TensorFlowInferenceInterface inference = inferences.get(id);
    //    double[] dst = new double[outputSize];
    //    inference.fetch(outputName, dst);
    //    promise.resolve(doubleArrayToReadableArray(dst));
    //} catch (Exception e) {
    //    promise.reject(e);
    //}
}

RCT_EXPORT_METHOD(graph:(NSString *)id resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    //try {
    //    TensorFlowInferenceInterface inference = inferences.get(id);
    //    RNTensorFlowGraphModule graphModule = reactContext.getNativeModule(RNTensorFlowGraphModule.class);
    //graphModule.init(id, inference.graph());
    //promise.resolve(true);
    //} catch (Exception e) {
    //    promise.reject(e);
    //}
}

RCT_EXPORT_METHOD(stats:(NSString *)id resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    //try {
    //    TensorFlowInferenceInterface inference = inferences.get(id);
    //    promise.resolve(inference.getStatString());
    //} catch (Exception e) {
    //    promise.reject(e);
    //}
}

RCT_EXPORT_METHOD(close:(NSString *)id)
{
    //try {
    //    TensorFlowInferenceInterface inference = inferences.get(id);
    //    promise.resolve(inference.getStatString());
    //} catch (Exception e) {
    //    promise.reject(e);
    //}
}

@end

