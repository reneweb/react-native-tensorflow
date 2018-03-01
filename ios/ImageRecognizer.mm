#import "ImageRecognizer.h"

#include "TensorFlowInference.h"

#include <string>
#include <fstream>

@implementation ImageRecognizer
{
    TensorFlowInference * inference;
    NSArray * labels;
    NSNumber * imageMean;
    NSNumber * imageStd;
}

- (id) initWithData:(NSString *)modelInput labels:(NSString *)labelsInput imageMean:(NSNumber *)imageMeanInput imageStd:(NSNumber *)imageStdInput
{
    self = [super init];
    if (self != nil) {
        imageMean = imageMeanInput != nil ? imageMeanInput : [NSNumber numberWithInt:117];
        imageStd = imageStdInput != nil ? imageStdInput : [NSNumber numberWithFloat:1];
        
        TensorFlowInference * tensorFlowInference = [[TensorFlowInference alloc] initWithModel:modelInput];
        inference = tensorFlowInference;
        
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:[labelsInput substringToIndex:[labelsInput length] - 4] ofType:@"txt"];
        if(bundlePath != NULL) {
            NSString *labelString = [NSString stringWithContentsOfFile:bundlePath encoding:NSUTF8StringEncoding error:nil];
            labels = [labelString componentsSeparatedByString:@"\n"];
        } else if ([[NSFileManager defaultManager] fileExistsAtPath:labelsInput]) {
            NSData * labelData = [[NSData alloc] initWithContentsOfFile:labelsInput];
            NSString * labelString = [[NSString alloc] initWithData:labelData encoding:NSUTF8StringEncoding];
            labels = [labelString componentsSeparatedByString:@"\n"];
        }  else {
            NSURL *labelsUrl = [NSURL URLWithString:labelsInput];
            NSData * labelData = [[NSData alloc] initWithContentsOfURL: labelsUrl];
            NSString * labelString = [[NSString alloc] initWithData:labelData encoding:NSUTF8StringEncoding];
            labels = [labelString componentsSeparatedByString:@"\n"];
        }
    }
    return self;
}

- (NSArray *) recognizeImage:(NSString *)image inputName:(NSString *)inputName inputSize:(NSNumber *)inputSize outputName:(NSString *)outputName maxResults:(NSNumber *)maxResults threshold:(NSNumber *)threshold
{
    NSString * inputNameResolved = inputName != nil ? inputName : @"input";
    NSString * outputNameResolved = outputName != nil ? outputName : @"output";
    NSNumber * inputSizeResolved = inputSize != nil ? inputSize : [NSNumber numberWithInt:224];
    NSNumber * maxResultsResolved = maxResults != nil ? maxResults : [NSNumber numberWithInt:3];
    NSNumber * thresholdResolved = threshold != nil ? threshold : [NSNumber numberWithFloat:0.1];
    
    NSData * imageData;
    NSString * imageType = [image hasSuffix:@"png"] ? @"png" : @"jpg";
    
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:[image substringToIndex:[image length] - 4] ofType:imageType];
    if(bundlePath != NULL) {
        imageData = [NSData dataWithContentsOfFile:bundlePath];
    } else if ([[NSFileManager defaultManager] fileExistsAtPath:image]) {
        imageData = [[NSData alloc] initWithContentsOfFile:image];
    } else {
        NSURL *imageUrl = [NSURL URLWithString:image];
        imageData = [[NSData alloc] initWithContentsOfURL: imageUrl];
    }
    
    tensorflow::Tensor tensor = createImageTensor(imageData, [imageType UTF8String], [inputSizeResolved floatValue], [imageMean floatValue], [imageStd floatValue]);
    [inference feed:inputNameResolved tensor:tensor];
    [inference run:[[NSArray alloc] initWithObjects:outputNameResolved, nil] enableStats:false];
    NSArray * outputs = [inference fetch:outputNameResolved];
    
    NSMutableArray * results = [NSMutableArray new];
    for (NSUInteger i = 0; i < [outputs count]; i++) {
        id output = [outputs objectAtIndex:i];
        if(output > thresholdResolved) {
            NSDictionary * entry = @{@"id": @(i), @"name": [labels count] > i ? labels[i] : @"unknown", @"confidence": output};
            [results addObject:entry];
        }
    }
    
    NSArray * resultsSorted = [results sortedArrayUsingComparator:^NSComparisonResult(id first, id second) {
        return [second[@"confidence"] compare:first[@"confidence"]];
    }];
    
    auto finalSize = MIN([resultsSorted count], [maxResultsResolved integerValue]);
    NSArray * finalResults = [resultsSorted subarrayWithRange:NSMakeRange(0, finalSize)];
    
    [inference reset];
    return finalResults;
}

tensorflow::Tensor createImageTensor(NSData * data, const char* image_type, float input_size, float input_mean, float input_std) {
    int image_width;
    int image_height;
    int image_channels;
    std::vector<tensorflow::uint8> image_data = imageAsVector(data, image_type, &image_width, &image_height, &image_channels);
    
    const int wanted_width = input_size;
    const int wanted_height = input_size;
    const int wanted_channels = 3;
    
    tensorflow::Tensor image_tensor(tensorflow::DT_FLOAT, tensorflow::TensorShape({1, wanted_height, wanted_width, wanted_channels}));
    auto image_tensor_mapped = image_tensor.tensor<float, 4>();
    tensorflow::uint8* in = image_data.data();
    
    float* out = image_tensor_mapped.data();
    for (int y = 0; y < wanted_height; ++y) {
        const int in_y = (y * image_height) / wanted_height;
        tensorflow::uint8* in_row = in + (in_y * image_width * image_channels);
        float* out_row = out + (y * wanted_width * wanted_channels);
        for (int x = 0; x < wanted_width; ++x) {
            const int in_x = (x * image_width) / wanted_width;
            tensorflow::uint8* in_pixel = in_row + (in_x * image_channels);
            float* out_pixel = out_row + (x * wanted_channels);
            for (int c = 0; c < wanted_channels; ++c) {
                out_pixel[c] = (in_pixel[c] - input_mean) / input_std;
            }
        }
    }
    
    return image_tensor;
}

std::vector<tensorflow::uint8> imageAsVector(NSData * data, const char* image_type, int* out_width, int* out_height, int* out_channels) {
    
    CFDataRef file_data_ref =  (__bridge CFDataRef)data;
    CGDataProviderRef image_provider = CGDataProviderCreateWithCFData(file_data_ref);
    
    CGImageRef image;
    if (strcasecmp(image_type, "png") == 0) {
        try {
            image = CGImageCreateWithPNGDataProvider(image_provider, NULL, true, kCGRenderingIntentDefault);
        } catch( std::exception& e ) {
            CFRelease(image_provider);
            CFRelease(file_data_ref);
            throw;
        }
    } else {
        try {
            image = CGImageCreateWithJPEGDataProvider(image_provider, NULL, true, kCGRenderingIntentDefault);
        } catch( std::exception& e ) {
            CFRelease(image_provider);
            CFRelease(file_data_ref);
            throw;
        }
    }
    
    const int width = (int)CGImageGetWidth(image);
    const int height = (int)CGImageGetHeight(image);
    const int channels = 4;
    CGColorSpaceRef color_space = CGColorSpaceCreateDeviceRGB();
    const int bytes_per_row = (width * channels);
    const int bytes_in_image = (bytes_per_row * height);
    std::vector<tensorflow::uint8> result(bytes_in_image);
    const int bits_per_component = 8;
    CGContextRef context = CGBitmapContextCreate(result.data(), width, height,
                                                 bits_per_component, bytes_per_row, color_space,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(color_space);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), image);
    CGContextRelease(context);
    CFRelease(image_provider);
    CFRelease(file_data_ref);
    
    *out_width = width;
    *out_height = height;
    *out_channels = channels;
    return result;
}

@end
