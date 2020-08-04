#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(AudioRecorder, NSObject)

RCT_EXTERN_METHOD(prepare:(nonnull NSNumber *)recorderId
                  withPath:(NSString * _Nullable)filename
                  withOptions:(NSDictionary *)options
                  withCallback:(RCTResponseSenderBlock)callback)

RCT_EXTERN_METHOD(record:(nonnull NSNumber *)recorderId
                  withCallback:(RCTResponseSenderBlock)callback)

RCT_EXTERN_METHOD(stop:(nonnull NSNumber *)recorderId
                  withCallback:(RCTResponseSenderBlock)callback)

RCT_EXTERN_METHOD(pause:(nonnull NSNumber *)recorderId
                  withCallback:(RCTResponseSenderBlock)callback)

RCT_EXTERN_METHOD(destroy:(nonnull NSNumber *)recorderId
                  withCallback:(RCTResponseSenderBlock)callback)

@end
