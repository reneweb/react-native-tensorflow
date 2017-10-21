#import "RNTensorFlowGraphOperations.h"

#import "RCTUtils.h"

#include "RNTensorFlowGraph.h"

@implementation RNTensorFlowGraphOperations

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(inputListLength:(NSString *)tId opName:(NSString *)opName name:(NSString *)name resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    try {
        int result = [self operation:tId opName:opName].input_size();
        resolve(@(result));
    } catch( std::exception& e ) {
        reject(RCTErrorUnspecified, @(e.what()), nil);
    }
}

RCT_EXPORT_METHOD(name:(NSString *)tId opName:(NSString *)opName resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    try {
        std::string result = [self operation:tId opName:opName].name();
        resolve(@(result.c_str()));
    } catch( std::exception& e ) {
        reject(RCTErrorUnspecified, @(e.what()), nil);
    }
}

RCT_EXPORT_METHOD(numOutputs:(NSString *)tId opName:(NSString *)opName resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    reject(RCTErrorUnspecified, @"Unsupported operation", nil);
}

RCT_EXPORT_METHOD(output:(NSString *)tId opName:(NSString *)opName index:(NSInteger *)index resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    reject(RCTErrorUnspecified, @"Unsupported operation", nil);
}

RCT_EXPORT_METHOD(outputList:(NSString *)tId opName:(NSString *)opName index:(NSInteger *)index length:(NSInteger *)length resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    reject(RCTErrorUnspecified, @"Unsupported operation", nil);
}

RCT_EXPORT_METHOD(outputListLength:(NSString *)tId opName:(NSString *)opName name:(NSString *)name resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    reject(RCTErrorUnspecified, @"Unsupported operation", nil);
}

RCT_EXPORT_METHOD(type:(NSString *)tId opName:(NSString *)opName resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    try {
        std::string result = [self operation:tId opName:opName].GetTypeName();
        resolve(@(result.c_str()));
    } catch( std::exception& e ) {
        reject(RCTErrorUnspecified, @(e.what()), nil);
    }
}

-(const tensorflow::NodeDef&) operation:(NSString *) tId opName:(NSString *) opName
{
    RNTensorFlowGraph * graph = [_bridge moduleForClass:[RNTensorFlowGraph class]];
    return [graph operation:tId name:opName];
}

@end
