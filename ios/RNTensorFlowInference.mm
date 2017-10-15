#import "RNTensorFlowInference.h"

#include "RNTensorFlowGraph.h"

#import "RCTUtils.h"

#include <string>
#include <fstream>

#include "tensorflow/core/framework/op_kernel.h"
#include "tensorflow/core/public/session.h"

namespace {
    class InputStream : public ::google::protobuf::io::CopyingInputStream {
    public:
        explicit InputStream(const std::string& file_name) : ifstream_(file_name.c_str(), std::ios::in | std::ios::binary) {
        }

        ~InputStream() {
            ifstream_.close();
        }

        int Read(void* buffer, int size) {
            if (!ifstream_) {
                return -1;
            }
            ifstream_.read(static_cast<char*>(buffer), size);
            return ifstream_.gcount();
        }

    private:
        std::ifstream ifstream_;
    };
}

@implementation RNTensorFlowInference
{
    std::unordered_map<std::string, std::shared_ptr<tensorflow::Session>> sessions;
    std::unordered_map<std::string, tensorflow::GraphDef> graphs;

    std::unordered_map<std::string, std::vector<std::string>> feedNames;
    std::unordered_map<std::string, std::vector<tensorflow::Tensor>> feedTensors;

    std::unordered_map<std::string, std::vector<std::string>> fetchNames;
    std::unordered_map<std::string, std::vector<tensorflow::Tensor>> fetchTensors;
}

@synthesize bridge = _bridge;

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(initTensorFlowInference:(NSString *)tId modelFilePath:(NSString *)modelFilePath resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    try {
        tensorflow::GraphDef tensorflow_graph;
        LOG(INFO) << "Graph created.";

        NSString* network_path = filePathForResource([modelFilePath substringToIndex:[modelFilePath length] - 3], @"pb");
        fileToProto([network_path UTF8String], &tensorflow_graph);

        tensorflow::SessionOptions options;

        tensorflow::Session* session_pointer = nullptr;
        tensorflow::Status session_status = tensorflow::NewSession(options, &session_pointer);
        if (!session_status.ok()) {
            std::string status_string = session_status.ToString();
            std::stringstream str;
            str << "Session create failed - " << status_string.c_str();
            throw std::runtime_error(str.str());
        }
        std::shared_ptr<tensorflow::Session> session(session_pointer);
        LOG(INFO) << "Session created.";

        LOG(INFO) << "Creating session.";
        tensorflow::Status s = session->Create(tensorflow_graph);
        if (!s.ok()) {
            std::stringstream str;
            str << "Could not create TensorFlow Graph: " << s;
            throw std::runtime_error(str.str());
        }

        sessions[[tId UTF8String]] = session;
        graphs[[tId UTF8String]] = tensorflow_graph;
        resolve(@1);
    } catch( std::exception& e ) {
        reject(RCTErrorUnspecified, @(e.what()), nil);
    }
}

RCT_EXPORT_METHOD(feedWithDims:(NSString *)tId inputName:(NSString *)inputName src:(NSArray *)src dims:(NSArray *)dims resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    try {
        int dimsCount = [dims count];
        std::vector<tensorflow::int64> dimsC(dimsCount);
        for (int i = 0; i < dimsCount; ++i) {
            dimsC[i] = [[dims objectAtIndex:i] intValue];
        }

        tensorflow::Tensor image_tensor(
                                        tensorflow::DT_FLOAT,
                                        tensorflow::TensorShape(dimsC));

        int srcCount = [src count];
        std::vector<float> srcC(srcCount);
        for (int i = 0; i < [src count]; ++i) {
            srcC[i] = [[src objectAtIndex:i] floatValue];
        }

        std::copy_n(srcC.begin(), srcC.size(), image_tensor.flat<float>().data());

        feedNames[[tId UTF8String]].push_back([inputName UTF8String]);
        feedTensors[[tId UTF8String]].push_back(image_tensor);
        resolve(@1);
    } catch( std::exception& e ) {
        reject(RCTErrorUnspecified, @(e.what()), nil);
    }
}

RCT_EXPORT_METHOD(feed:(NSString *)tId inputName:(NSString *)inputName src:(NSArray *)src resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    [self feedWithDims:tId inputName:inputName src:src dims:[NSArray new] resolver:resolve rejecter:reject];
}

RCT_EXPORT_METHOD(run:(NSString *)tId outputNames:(NSArray *)outputNames resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    [self runWithStatsFlag:tId outputNames:outputNames enableStats:false resolver:resolve rejecter:reject];
}

RCT_EXPORT_METHOD(runWithStatsFlag:(NSString *)tId outputNames:(NSArray *)outputNames enableStats:(bool)enableStats resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    try {
        std::shared_ptr<tensorflow::Session> session = sessions[[tId UTF8String]];
        tensorflow::GraphDef tensorflow_graph = graphs[[tId UTF8String]];

        std::vector<std::pair<std::string, tensorflow::Tensor>> feedC([outputNames count]);
        for (int i = 0; i < [outputNames count]; ++i) {
            feedC[i] = {[[outputNames objectAtIndex:i] UTF8String], feedTensors[[tId UTF8String]][i]};
        }

        int outputNamesCount = [outputNames count];
        std::vector<std::string> outputNamesC(outputNamesCount);
        for (int i = 0; i < [outputNames count]; ++i) {
            outputNamesC[i] = [[outputNames objectAtIndex:i] UTF8String];
        }

        std::vector<tensorflow::Tensor> outputs;
        tensorflow::Status run_status = session->Run(feedC, outputNamesC, {}, &outputs);

        if (!run_status.ok()) {
            tensorflow::LogAllRegisteredKernels();
            std::stringstream str;
            str << "Running model failed: " << run_status;
            throw std::runtime_error(str.str());
        }

        fetchNames[[tId UTF8String]] = outputNamesC;
        fetchTensors[[tId UTF8String]] = outputs;
        resolve(@1);
    } catch( std::exception& e ) {
        reject(RCTErrorUnspecified, @(e.what()), nil);
    }
}

RCT_EXPORT_METHOD(fetch:(NSString *)tId outputName:(NSString *)outputName outputSize:(NSInteger *)outputSize resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    try {
        int i = 0;
        tensorflow::Tensor *tensor;
        for(auto n : fetchNames[[tId UTF8String]]) {
            if (n == [outputName UTF8String]) {
                tensor = &fetchTensors[[tId UTF8String]][i];
            }
            ++i;
        }

        auto predictions = tensor->flat<float>();
        NSMutableArray * result = [NSMutableArray new];
        for (int index = 0; index < predictions.size(); index += 1) {
            [result addObject:@(predictions(index))];
        }

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            resolve(result);
        });

        delete tensor;
    } catch( std::exception& e ) {
        reject(RCTErrorUnspecified, @(e.what()), nil);
    }
}

RCT_EXPORT_METHOD(graph:(NSString *)tId resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    try {
        auto tensorflow_graph = graphs.find([tId UTF8String]);
        if(tensorflow_graph != graphs.end()) {
            RNTensorFlowGraph * graphModule = [_bridge moduleForClass:[RNTensorFlowGraph class]];
            [graphModule init:tId graph:tensorflow_graph->second];
            resolve(@1);
        } else {
            reject(RCTErrorUnspecified, @"Could not find graph with given id", nil);
        }
    } catch( std::exception& e ) {
        reject(RCTErrorUnspecified, @(e.what()), nil);
    }
}

RCT_EXPORT_METHOD(stats:(NSString *)tId resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    resolve(@1);
}

RCT_EXPORT_METHOD(close:(NSString *)tId resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    try {
        feedNames.erase([tId UTF8String]);
        feedTensors.erase([tId UTF8String]);
        fetchNames.erase([tId UTF8String]);
        fetchTensors.erase([tId UTF8String]);

        std::shared_ptr<tensorflow::Session> session = sessions[[tId UTF8String]];
        session->Close();
        sessions.erase([tId UTF8String]);

        tensorflow::GraphDef tensorflow_graph = graphs[[tId UTF8String]];
        RNTensorFlowGraph * graph = [self.bridge moduleForClass:[RNTensorFlowGraph class]];
        [graph close:tId];
        graphs.erase([tId UTF8String]);

        resolve(@1);
    } catch( std::exception& e ) {
        reject(RCTErrorUnspecified, @(e.what()), nil);
    }
}

NSString* filePathForResource(NSString* name, NSString* extension) {
    NSString* file_path = [[NSBundle mainBundle] pathForResource:name ofType:extension];
    if (file_path == NULL) {
        std::stringstream str;
        str << "Couldn't find '" << [name UTF8String] << "." << [extension UTF8String] << "' in bundle.";
        throw std::invalid_argument(str.str());
    }
    return file_path;
}

bool fileToProto(const std::string& file_name, ::google::protobuf::MessageLite* proto) {
    ::google::protobuf::io::CopyingInputStreamAdaptor stream(new InputStream(file_name));
    stream.SetOwnsCopyingStream(true);
    ::google::protobuf::io::CodedInputStream coded_stream(&stream);
    coded_stream.SetTotalBytesLimit(1024LL << 20, 512LL << 20);
    return proto->ParseFromCodedStream(&coded_stream);
}

@end
