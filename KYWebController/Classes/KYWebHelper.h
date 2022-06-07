//
//  KYWebHelper.h
//  KYJsBridge
//
//  Created by 康鹏鹏 on 2022/4/7.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KYWebHelper : NSObject

/// 字典转 json 字符串
/// @param dict 字典
+ (NSString *)dictionaryToJson:(NSDictionary *)dict;

/// 读取本地 JSON 文件
/// @param name 文件名，无需加文件后缀名
+ (NSDictionary *)readLocalJsonFileWithName:(NSString *)name;

/// 读取本地 plist 文件
/// @param name 文件名，无需加文件后缀名
+ (NSDictionary *)readLocalPlistFileWithName:(NSString *)name;

/// 查找 View 所在控制器
/// @param sourceView view
+ (UIViewController *)findViewController:(UIView *)sourceView;


@end

NS_ASSUME_NONNULL_END
