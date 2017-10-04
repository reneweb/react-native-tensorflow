#if __has_include("RCTBridge.h")
#import "RCTBridge.h"
#else
#import <React/RCTBridge.h>
#endif

#include "tensorflow/core/framework/op_kernel.h"
#include "tensorflow/core/public/session.h"

@interface RNTensorFlowGraphOperations : NSObject <RCTBridgeModule>

@end
