//
//  KYJsApiTest.m
//  KYJsBridge
//
//  Created by 康鹏鹏 on 2022/4/7.
//

#import "KYJsApiTest.h"

@implementation KYJsApiTest

- (void)jsApiHandler:(NSDictionary *)data context:(KYJsContext *)context callback:(KYJsApiResponseCallbackBlock)callback {
    [super jsApiHandler:data context:context callback:callback];
    if (callback) {
        NSDictionary *dict = @{
            @"key_01": @"①：OC 收到了jsApi，此处是处理后的回调数据",
            @"key_02": @"②：原生处理完成后，将结果回调给JS",
            @"key_03": @"③：回调结果虽然是个 id 类型，但是目前只能支持 NSDictionary，后续后支持自定义 Model 类型"
        };
        callback(dict);
    }
}
@end
