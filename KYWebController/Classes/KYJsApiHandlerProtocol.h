//
//  KYJsApiProtocol.h
//  KYJsBridge
//
//  Created by 康鹏鹏 on 2022/4/8.
//

#import <Foundation/Foundation.h>
#import "KYJsContext.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^KYJsApiResponseCallbackBlock)(id responseData);
/*
// TODO: KPP 此处需要扩展保活回调
typedef void (^KYJsApiResponseCallbackBlockKeepAlive)(id responseData, BOOL keepAlive);
 */

@protocol KYJsApiHandlerProtocol <NSObject>

@optional
/// JsApi 统一处理函数
/// @param data js 传递过来的参数
/// @param context 当前上下文
/// @param callback 处理结果给 js 回调，回调用一次即失效
- (void)jsApiHandler:(NSDictionary *)data context:(KYJsContext *)context callback:(KYJsApiResponseCallbackBlock __nullable)callback;

/*
/// JsApi 统一处理函数
/// @param data js 传递过来的参数
/// @param context 当前上下文
/// @param callback 处理结果给 js 回调，可以自己控制回调是否保活
- (void)jsApiHandler:(NSDictionary *)data context:(KYJsContext *)context callbackKeepAlive:(KYJsApiResponseCallbackBlockKeepAlive __nullable)callback;
*/
 
@end

NS_ASSUME_NONNULL_END
