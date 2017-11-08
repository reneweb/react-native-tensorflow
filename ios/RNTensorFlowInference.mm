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

        RNTensorFlowGraph * graphModule = [_bridge moduleForClass:[RNTensorFlowGraph class]];
        [graphModule init:tId graph:std::make_shared<tensorflow::GraphDef>(tensorflow_graph)];

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

        feedNames[[tId UTF8String]].push_back([inputName UTF8String]);
        feedTensors[[tId UTF8String]].push_back(tensor);
        resolve(@1);
    } catch( std::exception& e ) {
        reject(RCTErrorUnspecified, @(e.what()), nil);
    }
}

RCT_EXPORT_METHOD(run:(NSString *)tId outputNames:(NSArray *)outputNames enableStats:(BOOL)enableStats resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    try {
        std::shared_ptr<tensorflow::Session> session = sessions[[tId UTF8String]];

        std::vector<std::string> feedNamesForSession = feedNames[[tId UTF8String]];
        std::vector<std::pair<std::string, tensorflow::Tensor>> feedC(feedNamesForSession.size());
        for (int i = 0; i < feedNamesForSession.size(); ++i) {
            feedC[i] = {feedNamesForSession[i], feedTensors[[tId UTF8String]][i]};
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

RCT_EXPORT_METHOD(fetch:(NSString *)tId outputName:(NSString *)outputName resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
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

        NSArray *result = convertFetchResult(tensor);

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            resolve(result);
        });

        delete tensor;
    } catch( std::exception& e ) {
        reject(RCTErrorUnspecified, @(e.what()), nil);
    }
}

NSArray* convertFetchResult(tensorflow::Tensor *tensor) {
    if(tensor->dtype() == tensorflow::DataType::DT_DOUBLE) {
        auto predictions = tensor->flat<double>();
        NSMutableArray * result = [NSMutableArray new];
        for (int index = 0; index < predictions.size(); index += 1) {
            [result addObject:[NSNumber numberWithDouble:predictions(index)]];
        }

        return result;
    } else if(tensor->dtype() == tensorflow::DataType::DT_FLOAT) {
        auto predictions = tensor->flat<float>();
        NSMutableArray * result = [NSMutableArray new];
        for (int index = 0; index < predictions.size(); index += 1) {
            [result addObject:[NSNumber numberWithFloat:predictions(index)]];
        }

        return result;
    } else if(tensor->dtype() == tensorflow::DataType::DT_INT32) {
        auto predictions = tensor->flat<tensorflow::int32>();
        NSMutableArray * result = [NSMutableArray new];
        for (int index = 0; index < predictions.size(); index += 1) {
            [result addObject:[NSNumber numberWithInt:predictions(index)]];
        }

        return result;
    } else if(tensor->dtype() == tensorflow::DataType::DT_INT64) {
        auto predictions = tensor->flat<tensorflow::int64>();
        NSMutableArray * result = [NSMutableArray new];
        for (int index = 0; index < predictions.size(); index += 1) {
            [result addObject:[NSNumber numberWithLong:predictions(index)]];
        }

        return result;
    } else if(tensor->dtype() == tensorflow::DataType::DT_UINT8) {
        auto predictions = tensor->flat<tensorflow::uint8>();
        NSMutableArray * result = [NSMutableArray new];
        for (int index = 0; index < predictions.size(); index += 1) {
            [result addObject:[NSNumber numberWithInt:predictions(index)]];
        }

        return result;
    } else if(tensor->dtype() == tensorflow::DataType::DT_BOOL) {
        auto predictions = tensor->flat<bool>();
        NSMutableArray * result = [NSMutableArray new];
        for (int index = 0; index < predictions.size(); index += 1) {
            [result addObject:predictions(index) == true ? [NSNumber numberWithBool:YES] : [NSNumber numberWithBool:NO]];
        }

        return result;
    } else if(tensor->dtype() == tensorflow::DataType::DT_STRING) {
        auto predictions = tensor->flat<tensorflow::string>();
        NSMutableArray * result = [NSMutableArray new];
        for (int index = 0; index < predictions.size(); index += 1) {
            [result addObject:[NSString stringWithUTF8String:predictions(index).c_str()]];
        }

        return result;
    } else {
        throw std::invalid_argument("Invalid data type");
    }

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

        RNTensorFlowGraph * graph = [_bridge moduleForClass:[RNTensorFlowGraph class]];
        [graph close:tId];

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
