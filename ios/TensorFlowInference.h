#include <UIKit/UIKit.h>

#include "tensorflow/core/framework/op_kernel.h"
#include "tensorflow/core/public/session.h"

@interface TensorFlowInference: NSObject

- (id) initWithModel:(NSString *)modelLocation;
- (void) feed:(NSString *)inputName tensor:(tensorflow::Tensor)tensor;
- (void) run:(NSArray *)outputNames enableStats:(BOOL)enableStats;
- (NSArray *) fetch:(NSString *)outputName;
- (std::shared_ptr<tensorflow::GraphDef>) graph;
- (tensorflow::Status) close;

@end
