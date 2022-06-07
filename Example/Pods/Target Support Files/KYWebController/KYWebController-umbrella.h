#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "KYJsApiHandler.h"
#import "KYJsApiHandlerProtocol.h"
#import "KYJsContext.h"
#import "KYWebHelper.h"
#import "KYWebLoadingProgressLine.h"
#import "KYWebManager.h"
#import "KYWebManagerDelegate.h"
#import "KYWebViewController.h"

FOUNDATION_EXPORT double KYWebControllerVersionNumber;
FOUNDATION_EXPORT const unsigned char KYWebControllerVersionString[];

