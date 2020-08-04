#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>


@interface RCT_EXTERN_MODULE(AudioPlayer, NSObject)

RCT_EXTERN_METHOD(prepare:(nonnull NSNumber*)playerId
                  withPath:(NSString* _Nullable)path
                  withOptions:(NSDictionary *)options
                  withCallback:(RCTResponseSenderBlock)callback)

RCT_EXTERN_METHOD(seek:(nonnull NSNumber*)playerId
                  withPos:(nonnull NSNumber*)position
                  withCallback:(RCTResponseSenderBlock)callback)

RCT_EXTERN_METHOD(set:(nonnull NSNumber*)playerId
                  withOpts:(NSDictionary*)options
                  withCallback:(RCTResponseSenderBlock)callback)

RCT_EXTERN_METHOD(destroy:(nonnull NSNumber*)playerId
                  withCallback:(RCTResponseSenderBlock)callback)

RCT_EXTERN_METHOD(play:(nonnull NSNumber*)playerId
                  withCallback:(RCTResponseSenderBlock)callback)

RCT_EXTERN_METHOD(stop:(nonnull NSNumber*)playerId
                  withCallback:(RCTResponseSenderBlock)callback)

RCT_EXTERN_METHOD(pause:(nonnull NSNumber*)playerId
                  withCallback:(RCTResponseSenderBlock)callback)

RCT_EXTERN_METHOD(resume:(nonnull NSNumber*)playerId
                  withCallback:(RCTResponseSenderBlock)callback)

RCT_EXTERN_METHOD(getCurrentTime:(nonnull NSNumber*)playerId
                  withCallback:(RCTResponseSenderBlock)callback)

RCT_EXTERN_METHOD(test)

@end
