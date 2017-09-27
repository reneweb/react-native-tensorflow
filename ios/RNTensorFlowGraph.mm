#import "RNTensorFlowGraph.h"

@implementation RNTensorFlowGraph

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(importGraphDef:(NSString *)id graphDef:(NSString *)graphDef)
{
    //Graph graph = graphs.get(id);
    //if(graph != null) {
    //    graph.importGraphDef(Base64.decode(graphDef, Base64.DEFAULT));
    //}
}

RCT_EXPORT_METHOD(importGraphDefWithPrefix:(NSString *)id graphDef:(NSString *)graphDef prefix:(NSString *)prefix)
{
    //Graph graph = graphs.get(id);
    //if(graph != null) {
    //    graph.importGraphDef(Base64.decode(graphDef, Base64.DEFAULT), prefix);
    //}
}

RCT_EXPORT_METHOD(toGraphDef:(NSString *)id resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    //Graph graph = graphs.get(id);
    //if(graph != null) {
    //    graph.importGraphDef(Base64.decode(graphDef, Base64.DEFAULT));
    //}
}

RCT_EXPORT_METHOD(operation:(NSString *)id name:(NSString *)name resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    //try {
    //  RNTensorFlowGraphOperationsModule operationsModule =
    //  reactContext.getNativeModule(RNTensorFlowGraphOperationsModule.class);
    //  operationsModule.init();
    //  promise.resolve(true);
    //} catch (Exception e) {
    //  promise.reject(e);
    //}
}

RCT_EXPORT_METHOD(close:(NSString *)id)
{
    //Graph graph = graphs.get(id);
    //if(graph != null) {
    //    graph.close();
    //}
}


@end

