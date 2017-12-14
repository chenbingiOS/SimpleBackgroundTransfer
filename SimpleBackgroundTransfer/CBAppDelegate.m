//
//  CBAppDelegate.m
//  SimpleBackgroundTransfer
//
//  Created by 陈冰 on 2017/12/13.
//  Copyright © 2017年 ChenBing. All rights reserved.
//

#import "CBAppDelegate.h"

@implementation CBAppDelegate

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)(void))completionHandler {
    BLog();
    
    self.backgroundSessionCompletionHandler = completionHandler;
}
- (void)applicationDidBecomeActive:(UIApplication *)application {}
- (void)applicationWillResignActive:(UIApplication *)application {}

@end
