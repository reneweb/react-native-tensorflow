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
        
        NSString * inputName = data[@"name"];
        NSArray * srcData = data[@"data"];
        NSArray * shape = data[@"shape"] ? data[@"shape"] : [NSArray new];
        
        tensorflow::DataType dtype;
        if(data[@"dtype"]) {
            tensorflow::DataType_Parse([[NSString stringWithFormat:@"%@%@", @"DT_", [data[@"dtype"] uppercaseString]] UTF8String] , &dtype);
        } else {
            dtype = tensorflow::DataType::DT_DOUBLE;
        }
        
        int shapeCount = [shape count];
        std::vector<tensorflow::int64> shapeC(shapeCount);
        for (int i = 0; i < shapeCount; ++i) {
            shapeC[i] = [[shape objectAtIndex:i] intValue];
        }
        
        tensorflow::Tensor tensor(dtype, tensorflow::TensorShape(shapeC));
        
        if(dtype == tensorflow::DataType::DT_DOUBLE) {
            int srcDataCount = [srcData count];
            std::vector<double> srcDataC(srcDataCount);
            for (int i = 0; i < [srcData count]; ++i) {
                srcDataC[i] = [[srcData objectAtIndex:i] doubleValue];
            }
            
            std::copy_n(srcDataC.begin(), srcDataC.size(), tensor.flat<double>().data());
        } else if(dtype == tensorflow::DataType::DT_FLOAT) {
            int srcDataCount = [srcData count];
            std::vector<float> srcDataC(srcDataCount);
            for (int i = 0; i < [srcData count]; ++i) {
                srcDataC[i] = [[srcData objectAtIndex:i] floatValue];
            }
            
            std::copy_n(srcDataC.begin(), srcDataC.size(), tensor.flat<float>().data());
        } else if(dtype == tensorflow::DataType::DT_INT32) {
            int srcDataCount = [srcData count];
            std::vector<int32_t> srcDataC(srcDataCount);
            for (int i = 0; i < [srcData count]; ++i) {
                srcDataC[i] = [[srcData objectAtIndex:i] intValue];
            }
            
            std::copy_n(srcDataC.begin(), srcDataC.size(), tensor.flat<int32_t>().data());
        } else if(dtype == tensorflow::DataType::DT_INT64) {
            int srcDataCount = [srcData count];
            std::vector<int64_t> srcDataC(srcDataCount);
            for (int i = 0; i < [srcData count]; ++i) {
                srcDataC[i] = [[srcData objectAtIndex:i] longValue];
            }
            
            std::copy_n(srcDataC.begin(), srcDataC.size(), tensor.flat<int64_t>().data());
        } else if(dtype == tensorflow::DataType::DT_UINT8) {
            int srcDataCount = [srcData count];
            std::vector<u_int8_t> srcDataC(srcDataCount);
            for (int i = 0; i < [srcData count]; ++i) {
                srcDataC[i] = [[srcData objectAtIndex:i] intValue];
            }
            
            std::copy_n(srcDataC.begin(), srcDataC.size(), tensor.flat<u_int8_t>().data());
        } else if(dtype == tensorflow::DataType::DT_BOOL) {
            int srcDataCount = [srcData count];
            std::vector<bool> srcDataC(srcDataCount);
            for (int i = 0; i < [srcData count]; ++i) {
                srcDataC[i] = [[srcData objectAtIndex:i] boolValue];
            }
            
            std::copy_n(srcDataC.begin(), srcDataC.size(), tensor.flat<bool>().data());
        } else if(dtype == tensorflow::DataType::DT_STRING) {
            int srcDataCount = [srcData count];
            std::vector<std::string> srcDataC(srcDataCount);
            for (int i = 0; i < [srcData count]; ++i) {
                srcDataC[i] = [[srcData objectAtIndex:i] UTF8String];
            }
            
            std::copy_n(srcDataC.begin(), srcDataC.size(), tensor.flat<std::string>().data());
        } else {
            throw std::invalid_argument("Invalid data type");
        }
        
        TensorFlowInference * inference = inferenceMap[[tId UTF8String]];
        [inference feed:inputName tensor:tensor];
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
