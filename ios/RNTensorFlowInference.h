#if __has_include("RCTBridge.h")
#import "RCTBridge.h"
#else
#import <React/RCTBridge.h>
#endif

@interface RNTensorFlowInference : NSObject <RCTBridgeModule>

@end
