#import "TensorFlowInference.h"

#include <string>
#include <fstream>


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

@implementation TensorFlowInference
{
    std::shared_ptr<tensorflow::Session> session;
    std::shared_ptr<tensorflow::GraphDef> tensorflowGraph;
    
    std::vector<std::string> feedNames;
    std::vector<tensorflow::Tensor> feedTensors;
    
    std::vector<std::string> fetchNames;
    std::vector<tensorflow::Tensor> fetchTensors;
}

- (id) initWithModel:(NSString *)modelLocation {
    self = [super init];
    if (self != nil) {
        return [self initTensorFlow:modelLocation];
    }
    return self;
}

- (id) initTensorFlow:(NSString *)modelLocation
{
    tensorflow::GraphDef graph;
    LOG(INFO) << "Graph created.";
    
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:[modelLocation substringToIndex:[modelLocation length] - 3] ofType:@"pb"];
    if(bundlePath != NULL) {
        fileToProto([bundlePath UTF8String], &graph);
    } else if ([[NSFileManager defaultManager] fileExistsAtPath:modelLocation]) {
        NSData *data = [[NSData alloc] initWithContentsOfFile:modelLocation];
        
        const void *buf = [data bytes];
        unsigned long numBytes = [data length];
        
        graph.ParseFromArray(buf, numBytes);
    } else {
        NSURL *url = [NSURL URLWithString:modelLocation];
        NSData *data = [NSData dataWithContentsOfURL:url];
        
        const void *buf = [data bytes];
        unsigned long numBytes = [data length];
        
        graph.ParseFromArray(buf, numBytes);
    }
    
    tensorflow::SessionOptions options;
    
    tensorflow::Session* session_pointer = nullptr;
    tensorflow::Status session_status = tensorflow::NewSession(options, &session_pointer);
    if (!session_status.ok()) {
        std::string status_string = session_status.ToString();
        std::stringstream str;
        str << "Session create failed - " << status_string.c_str();
        throw std::runtime_error(str.str());
    }
    std::shared_ptr<tensorflow::Session> sess(session_pointer);
    LOG(INFO) << "Session created.";
    
    LOG(INFO) << "Creating session.";
    tensorflow::Status s = sess->Create(graph);
    if (!s.ok()) {
        std::stringstream str;
        str << "Could not create TensorFlow Graph: " << s;
        throw std::runtime_error(str.str());
    }
    
    session = sess;
    tensorflowGraph = std::make_shared<tensorflow::GraphDef>(graph);
    
    return self;
}

- (void) feed:(NSString *)inputName tensor:(tensorflow::Tensor)tensor
{
    feedNames.push_back([inputName UTF8String]);
    feedTensors.push_back(tensor);
}

- (void) run:(NSArray *)outputNames enableStats:(BOOL)enableStats
{
    std::vector<std::pair<std::string, tensorflow::Tensor>> feedC(feedNames.size());
    for (int i = 0; i < feedNames.size(); ++i) {
        feedC[i] = {feedNames[i], feedTensors[i]};
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
    
    fetchNames = outputNamesC;
    fetchTensors = outputs;
}

- (NSArray *) fetch:(NSString *)outputName
{
    int i = 0;
    tensorflow::Tensor *tensor = nullptr;
    for(auto n : fetchNames) {
        if (n == [outputName UTF8String]) {
            tensor = &fetchTensors[i];
        }
        ++i;
    }
    
    return convertFetchResult(tensor);
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

-(std::shared_ptr<tensorflow::GraphDef>) graph
{
    return tensorflowGraph;
}

-(void) reset
{
    feedNames.clear();
    feedTensors.clear();
    fetchNames.clear();
    fetchTensors.clear();
}

-(tensorflow::Status) close
{
    feedNames.clear();
    feedTensors.clear();
    fetchNames.clear();
    fetchTensors.clear();
    
    return session->Close();
}

bool fileToProto(const std::string& file_name, ::google::protobuf::MessageLite* proto) {
    ::google::protobuf::io::CopyingInputStreamAdaptor stream(new InputStream(file_name));
    stream.SetOwnsCopyingStream(true);
    ::google::protobuf::io::CodedInputStream coded_stream(&stream);
    coded_stream.SetTotalBytesLimit(1024LL << 20, 512LL << 20);
    return proto->ParseFromCodedStream(&coded_stream);
}

@end
