#import "RNTensorFlowGraph.h"

#import "RCTUtils.h"

#include "RNTensorFlowGraphOperations.h"

@implementation RNTensorFlowGraph {
    std::unordered_map<std::string, std::shared_ptr<tensorflow::GraphDef>> graphs;
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

- (void)init:(NSString *)tId graph:(std::shared_ptr<tensorflow::GraphDef>)graph
{
    graphs[[tId UTF8String]] = graph;
}

- (const tensorflow::NodeDef&)operation:(NSString *)tId name:(NSString *)name
{
    auto graph = graphs.find([tId UTF8String]);
    if(graph != graphs.end()) {
        auto nodes = graph->second->node();
        for(auto const& node: nodes) {
            if(node.op() == [name UTF8String]) {
                return node;
            }
        }
    }
    
    throw std::invalid_argument("Node / Operation with name not found");
    
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
            graph->second->ParseFromString([graphDefDecodedString UTF8String]);
            resolve(@1);
        } else {
            reject(RCTErrorUnspecified, @"Could not find graph with given id", nil);
        }
    } catch( std::exception& e ) {
        reject(RCTErrorUnspecified, @(e.what()), nil);
    }
}

RCT_EXPORT_METHOD(toGraphDef:(NSString *)tId resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    try {
        auto graph = graphs.find([tId UTF8String]);
        if(graph != graphs.end()) {
            resolve(@(graph->second->SerializeAsString().c_str()));
        } else {
            reject(RCTErrorUnspecified, @"Could not find graph with given id", nil);
        }
    } catch( std::exception& e ) {
        reject(RCTErrorUnspecified, @(e.what()), nil);
    }
}

RCT_EXPORT_METHOD(close:(NSString *)tId resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    try {
        auto graph = graphs.find([tId UTF8String]);
        if(graph != graphs.end()) {
            graph->second->Clear();
            graphs.erase(graph);
            resolve(@1);
        } else {
            reject(RCTErrorUnspecified, @"Could not find graph with given id", nil);
        }
    } catch( std::exception& e ) {
        reject(RCTErrorUnspecified, @(e.what()), nil);
    }
}

@end
