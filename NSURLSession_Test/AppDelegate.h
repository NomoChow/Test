//
//  AppDelegate.h
//  NSURLSession_Test
//
//  Created by 周建顺 on 15/7/3.
//  Copyright (c) 2015年 周建顺. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


@property (nonatomic,copy) void (^backgroundCompleteHandler)(void) ;
@property (nonatomic,weak) NSURLSessionDownloadTask *backgroundDownloadTask;

@end

