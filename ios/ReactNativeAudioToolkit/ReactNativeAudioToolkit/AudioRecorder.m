#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(AudioRecorder, NSObject)

RCT_EXTERN_METHOD(prepare:(nonnull NSInteger *)recorderId
                  withPath:(NSString * _Nullable)filename
                  withOptions:(NSDictionary *)options
                  withCallback:(RCTResponseSenderBlock)callback)

RCT_EXTERN_METHOD(record:(nonnull NSInteger *)recorderId
                  withCallback:(RCTResponseSenderBlock)callback)

RCT_EXTERN_METHOD(stop:(nonnull NSInteger *)recorderId
                  withCallback:(RCTResponseSenderBlock)callback)

RCT_EXTERN_METHOD(pause:(nonnull NSInteger *)recorderId
                  withCallback:(RCTResponseSenderBlock)callback)

RCT_EXTERN_METHOD(destroy:(nonnull NSInteger *)recorderId
                  withCallback:(RCTResponseSenderBlock)callback)

@end
