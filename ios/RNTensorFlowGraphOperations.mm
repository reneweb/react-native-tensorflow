#import "RNTensorFlowGraphOperations.h"

@implementation RNTensorFlowGraphOperations

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(inputListLength:(NSString *)id opName:(NSString *)opName name:(NSString *)name resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    //try {
    //    Operation graphOperation = getGraphOperation(id, opName);
    //    promise.resolve(graphOperation.inputListLength(name));
    //} catch (Exception e) {
    //    promise.reject(e);
    //}
}

RCT_EXPORT_METHOD(name:(NSString *)id opName:(NSString *)opName resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    //try {
    //    Operation graphOperation = getGraphOperation(id, opName);
    //    promise.resolve(graphOperation.name());
    //} catch (Exception e) {
    //    promise.reject(e);
    //}
}

RCT_EXPORT_METHOD(numOutputs:(NSString *)id opName:(NSString *)opName resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    //try {
    //    Operation graphOperation = getGraphOperation(id, opName);
    //    promise.resolve(graphOperation.numOutputs());
    //} catch (Exception e) {
    //    promise.reject(e);
    //}
}

RCT_EXPORT_METHOD(output:(NSString *)id opName:(NSString *)opName index:(NSInteger *)index resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    //try {
    //    Operation graphOperation = getGraphOperation(id, opName);
    //    promise.resolve(OutputConverter.convert(graphOperation.output(index)));
    //} catch (Exception e) {
    //    promise.reject(e);
    //}
}

RCT_EXPORT_METHOD(outputList:(NSString *)id opName:(NSString *)opName index:(NSInteger *)index length:(NSInteger *)length resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    //try {
    //    Operation graphOperation = getGraphOperation(id, opName);
    //    Output[] outputs = graphOperation.outputList(index, length);
    //    WritableArray outputsConverted = new WritableNativeArray();
    //    for (Output output : outputs) {
    //        outputsConverted.pushMap(OutputConverter.convert(output));
    //    }
    //    promise.resolve(outputsConverted);
    //} catch (Exception e) {
    //    promise.reject(e);
    //}
}

RCT_EXPORT_METHOD(outputListLength:(NSString *)id opName:(NSString *)opName name:(NSString *)name resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    //try {
    //    Operation graphOperation = getGraphOperation(id, opName);
    //    promise.resolve(graphOperation.outputListLength(name));
    //} catch (Exception e) {
    //    promise.reject(e);
    //}
}

RCT_EXPORT_METHOD(type:(NSString *)id opName:(NSString *)opName resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    //try {
    //    Operation graphOperation = getGraphOperation(id, opName);
    //    promise.resolve(graphOperation.type());
    //} catch (Exception e) {
    //    promise.reject(e);
    //}
}

@end

