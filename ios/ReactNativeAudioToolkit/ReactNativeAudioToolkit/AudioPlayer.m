#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>


@interface RCT_EXTERN_MODULE(AudioPlayer, NSObject)

RCT_EXTERN_METHOD(prepare:(nonnull NSInteger*)playerId
                  withPath:(NSString* _Nullable)path
                  withOptions:(NSDictionary *)options
                  withCallback:(RCTResponseSenderBlock)callback)

RCT_EXTERN_METHOD(seek:(nonnull NSInteger*)playerId
                  withPos:(nonnull NSNumber*)position
                  withCallback:(RCTResponseSenderBlock)callback)

RCT_EXTERN_METHOD(set:(nonnull NSInteger*)playerId
                  withOptions:(NSDictionary*)options
                  withCallback:(RCTResponseSenderBlock)callback)

RCT_EXTERN_METHOD(destroy:(nonnull NSInteger*)playerId
                  withCallback:(RCTResponseSenderBlock)callback)

RCT_EXTERN_METHOD(play:(nonnull NSInteger*)playerId
                  withCallback:(RCTResponseSenderBlock)callback)

RCT_EXTERN_METHOD(stop:(nonnull NSInteger*)playerId
                  withCallback:(RCTResponseSenderBlock)callback)

RCT_EXTERN_METHOD(pause:(nonnull NSInteger*)playerId
                  withCallback:(RCTResponseSenderBlock)callback)

RCT_EXTERN_METHOD(resume:(nonnull NSInteger*)playerId
                  withCallback:(RCTResponseSenderBlock)callback)

RCT_EXTERN_METHOD(getCurrentTime:(nonnull NSInteger*)playerId
                  withCallback:(RCTResponseSenderBlock)callback)

RCT_EXTERN_METHOD(test)

@end
