#if __has_include("RCTBridge.h")
#import "RCTBridge.h"
#else
#import <React/RCTBridge.h>
#endif

#include "tensorflow/core/framework/op_kernel.h"
#include "tensorflow/core/public/session.h"

@interface RNTensorFlowGraph : NSObject <RCTBridgeModule>

-(void)init:(NSString *)tId graph:(std::shared_ptr<tensorflow::GraphDef>)graph;
-(void)close:(NSString *)tId;
-(const tensorflow::NodeDef&)operation:(NSString *)tId name:(NSString *)name;

@end
