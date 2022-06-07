//
//  KYWebHelper.m
//  KYJsBridge
//
//  Created by 康鹏鹏 on 2022/4/7.
//

#import "KYWebHelper.h"

@implementation KYWebHelper

+ (NSString *)dictionaryToJson:(NSDictionary*)dict {
    NSError*parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&parseError];
    if (jsonData == nil) return @"";
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

+ (NSDictionary *)readLocalJsonFileWithName:(NSString *)name {
    // 获取文件路径
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"json"];
    // 将文件数据化
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    // 对数据进行JSON格式化并返回字典形式
    return [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
}

+ (NSDictionary *)readLocalPlistFileWithName:(NSString *)name {
    // 获取文件路径
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"plist"];
    //读取plist
    NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    return plistDict;
}

+ (UIViewController *)findViewController:(UIView *)sourceView {
    id target = sourceView;
    while (target) {
        target = ((UIResponder *)target).nextResponder;
        if ([target isKindOfClass:[UIViewController class]]) {
            break;
        }
    }
    return target;
}


@end
