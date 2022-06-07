//
//  KYJsApiTest.h
//  KYJsBridge
//
//  Created by 康鹏鹏 on 2022/4/7.
//

#import <KYJsApiHandler.h>
#import <KYJsApiHandlerProtocol.h>

NS_ASSUME_NONNULL_BEGIN

/// 也可以直接继承<KYJsApiHandlerProtocol> 协议，实现方法
/// 这样会缺少父类扩展功能

@interface KYJsApiTest : KYJsApiHandler

@end

NS_ASSUME_NONNULL_END
