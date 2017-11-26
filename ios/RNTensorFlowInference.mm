#import "RNTensorFlowInference.h"

#include "RNTensorFlowGraph.h"
#include "TensorFlowInference.h"

#import "RCTUtils.h"

#include <string>
#include <fstream>

#include "tensorflow/core/framework/op_kernel.h"
#include "tensorflow/core/public/session.h"

@implementation RNTensorFlowInference
{
    std::unordered_map<std::string, TensorFlowInference *> inferenceMap;
}

@synthesize bridge = _bridge;

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(initTensorFlowInference:(NSString *)tId modelLocation:(NSString *)modelLocation resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    try {
        TensorFlowInference * inference = [[TensorFlowInference alloc] initWithModel:modelLocation];
        inferenceMap[[tId UTF8String]] = inference;
        
        RNTensorFlowGraph * graphModule = [_bridge moduleForClass:[RNTensorFlowGraph class]];
        [graphModule init:tId graph:[inference graph]];
        
        resolve(@1);
    } catch( std::exception& e ) {
        reject(RCTErrorUnspecified, @(e.what()), nil);
    }
}

RCT_EXPORT_METHOD(feed:(NSString *)tId data:(NSDictionary *)data resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    try {
        TensorFlowInference * inference = inferenceMap[[tId UTF8String]];
        [inference feed:data];
        resolve(@1);
    } catch( std::exception& e ) {
        reject(RCTErrorUnspecified, @(e.what()), nil);
    }
}

RCT_EXPORT_METHOD(run:(NSString *)tId outputNames:(NSArray *)outputNames enableStats:(BOOL)enableStats resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    try {
        TensorFlowInference * inference = inferenceMap[[tId UTF8String]];
        [inference run:outputNames enableStats:enableStats];
        resolve(@1);
    } catch( std::exception& e ) {
        reject(RCTErrorUnspecified, @(e.what()), nil);
    }
}

RCT_EXPORT_METHOD(fetch:(NSString *)tId outputName:(NSString *)outputName resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    try {
        TensorFlowInference * inference = inferenceMap[[tId UTF8String]];
        NSArray *result = [inference fetch:outputName];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            resolve(result);
        });
    } catch( std::exception& e ) {
        reject(RCTErrorUnspecified, @(e.what()), nil);
    }
}

RCT_EXPORT_METHOD(close:(NSString *)tId resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    try {
        TensorFlowInference * inference = inferenceMap[[tId UTF8String]];
        [inference close];
        inferenceMap.erase([tId UTF8String]);
        
        RNTensorFlowGraph * graph = [_bridge moduleForClass:[RNTensorFlowGraph class]];
        [graph close:tId];
        
        resolve(@1);
    } catch( std::exception& e ) {
        reject(RCTErrorUnspecified, @(e.what()), nil);
    }
}

@end
