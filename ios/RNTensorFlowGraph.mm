#import "RNTensorFlowGraph.h"

#import "RCTUtils.h"

#include "RNTensorFlowGraphOperations.h"

@implementation RNTensorFlowGraph {
    std::unordered_map<std::string, tensorflow::GraphDef> graphs;
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

- (void)init:(NSString *)tId graph:(tensorflow::GraphDef)graph
{
    graphs[[tId UTF8String]] = graph;
}

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(importGraphDef:(NSString *)tId graphDef:(NSString *)graphDef resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    [self importGraphDefWithPrefix:tId graphDef:graphDef prefix:@"" resolver:resolve rejecter:reject];
}

RCT_EXPORT_METHOD(importGraphDefWithPrefix:(NSString *)tId graphDef:(NSString *)graphDef prefix:(NSString *)prefix resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    try {
        NSData *graphDefDecodedData = [[NSData alloc] initWithBase64EncodedString:graphDef options:0];
        NSString *graphDefDecodedString = [[NSString alloc] initWithData:graphDefDecodedData encoding:NSUTF8StringEncoding];
    
        auto graph = graphs.find([tId UTF8String]);
        if(graph != graphs.end()) {
            graph->second.ParseFromString([graphDefDecodedString UTF8String]); //prefix??
        } else {
            reject(RCTErrorUnspecified, @"Could not find graph with given id", nil);
        }
    } catch( std::exception& e ) {
        reject(RCTErrorUnspecified, e.what());
    }
}

RCT_EXPORT_METHOD(toGraphDef:(NSString *)tId resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    try {
        auto graph = graphs.find([tId UTF8String]);
        if(graph != graphs.end()) {
            resolve(@(graph->second.SerializeAsString().c_str()));
        } else {
            reject(RCTErrorUnspecified, @"Could not find graph with given id", nil);
        }
    } catch( std::exception& e ) {
        reject(RCTErrorUnspecified, e.what());
    }
}

RCT_EXPORT_METHOD(operation:(NSString *)tId name:(NSString *)name resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    reject(RCTErrorUnspecified, @"Unsupported operation", nil);
}

RCT_EXPORT_METHOD(close:(NSString *)tId resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    try {
        auto graph = graphs.find([tId UTF8String]);
        if(graph != graphs.end()) {
            graph->second.Clear();
            graphs.erase(graph);
        } else {
            reject(RCTErrorUnspecified, @"Could not find graph with given id", nil);
        }
    } catch( std::exception& e ) {
        reject(RCTErrorUnspecified, e.what());
    }
}

@end

