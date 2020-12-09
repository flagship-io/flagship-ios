//
//  AppDelegate.m
//  objcExample
//
//  Created by Adel on 24/10/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

#import "AppDelegate.h"
//#import "objcExample-Bridging-Header.h"
//#import "objcExample-Swift.h"
//#import <FlagShip-Swift.h>
 

@import Flagship;
 

 
 

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
    /// init config object
//    FSConfig * config = [[FSConfig alloc] init:FlagshipModeDECISION_API timeout:2];
//    
//    
//    
//    
//    
//   // [Flagship sharedInstance] updateContext:{@"":YES}
//    /// Start the sdk
//    [[Flagship sharedInstance] startWithEnvId:@"bkk9glocmjcg0vtmdlng" apiKey:@"DxAcxlnRB9yFBZYtLDue1q01dcXZCw6aM49CQB23" visitorId:NULL config:config onStartDone:^(enum FlagshipResult result) {
//        
//        if (result == FlagshipResultReady){
//
//          dispatch_async(dispatch_get_main_queue(), ^{
//              
//              /// update UI
//         });
//        }else{
//            
//            /// An error occurs or the SDK is disabled
//        }
//        
//    }];
    


    
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
