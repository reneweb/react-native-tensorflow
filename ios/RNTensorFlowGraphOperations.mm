#import "RNTensorFlowGraphOperations.h"

#import "RCTUtils.h"

@implementation RNTensorFlowGraphOperations

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(inputListLength:(NSString *)tId opName:(NSString *)opName name:(NSString *)name resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    reject(RCTErrorUnspecified, @"Unsupported operation", nil);
}

RCT_EXPORT_METHOD(name:(NSString *)tId opName:(NSString *)opName resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    reject(RCTErrorUnspecified, @"Unsupported operation", nil);
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
    reject(RCTErrorUnspecified, @"Unsupported operation", nil);
}

@end
