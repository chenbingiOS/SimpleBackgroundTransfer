//
//  CBAppDelegate.h
//  SimpleBackgroundTransfer
//
//  Created by 陈冰 on 2017/12/13.
//  Copyright © 2017年 ChenBing. All rights reserved.
//

@import UIKit;

@interface CBAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (copy) void(^backgroundSessionCompletionHandler)(void);

@end
