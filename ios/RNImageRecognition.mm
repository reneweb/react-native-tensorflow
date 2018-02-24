#import "RNImageRecognition.h"

#include "ImageRecognizer.h"

#import "RCTUtils.h"

#include <string>
#include <fstream>

#include "tensorflow/core/framework/op_kernel.h"
#include "tensorflow/core/public/session.h"

@implementation RNImageRecognition
{
    std::unordered_map<std::string, ImageRecognizer *> imageRecognizers;
}

@synthesize bridge = _bridge;

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(initImageRecognizer:(NSString *)tId data:(NSDictionary *)data resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    try {
        NSString * model = data[@"model"];
        NSString * labels = data[@"labels"];
        NSNumber * imageMean = [data objectForKey:@"imageMean"];
        NSNumber * imageStd = [data objectForKey:@"imageStd"];
        
        ImageRecognizer * imageRecognizer = [[ImageRecognizer alloc] initWithData:model labels:labels imageMean:imageMean imageStd:imageStd];
        imageRecognizers[[tId UTF8String]] = imageRecognizer;
        
        resolve(@1);
    } catch( std::exception& e ) {
        reject(RCTErrorUnspecified, @(e.what()), nil);
    }
}

RCT_EXPORT_METHOD(recognize:(NSString *)tId data:(NSDictionary *)data resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    try {
        NSString * image = data[@"image"];
        NSString * inputName = [data objectForKey:@"inputName"];
        NSNumber * inputSize = [data objectForKey:@"inputSize"];
        NSString * outputName = [data objectForKey:@"outputName"];
        NSNumber * maxResults = [data objectForKey:@"maxResults"];
        NSNumber * threshold = [data objectForKey:@"threshold"];
        
        ImageRecognizer * imageRecognizer = imageRecognizers[[tId UTF8String]];
        NSArray * result = [imageRecognizer recognizeImage:image inputName:inputName inputSize:inputSize outputName:outputName maxResults:maxResults threshold:threshold];
        resolve(result);
    } catch( std::exception& e ) {
        reject(RCTErrorUnspecified, @(e.what()), nil);
    }
}

RCT_EXPORT_METHOD(close:(NSString *)tId resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    try {
        imageRecognizers.erase([tId UTF8String]);
        resolve(@1);
    } catch( std::exception& e ) {
        reject(RCTErrorUnspecified, @(e.what()), nil);
    }
}

@end
