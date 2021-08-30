//
//  HomeStoreViewCtrl.m
//  objcExample
//
//  Created by Adel on 25/10/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

#import "HomeStoreViewCtrl.h"

@import Flagship;

@interface HomeStoreViewCtrl ()

@end

@implementation HomeStoreViewCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}



- (IBAction)startFlagShip{
    
    
    // Define context
    [[Flagship sharedInstance] updateContext:@{@"basketNumber":@200, @"isVipUser":@YES}];
    
    [[Flagship sharedInstance] updateContext:@{@"basketNumber":@10, @"isVip":@YES, @"name":@"alice", @"valueKey":@1.2}];
    
    
    
    
    [[Flagship sharedInstance] updateContext:@{@"Boolean_Key":@YES,@"String_Key":@"june",@"Number_Key":@200}];

    FSConfig * config = [[FSConfig alloc] init:FlagshipModeDECISION_API timeout:2 authenticated:YES isConsent:YES];

    [[Flagship sharedInstance] startWithEnvId:@"bkk9glocmjcg0vtmdlng" apiKey:@"DxAcxlnRB9yFBZYtLDue1q01dcXZCw6aM49CQB23" visitorId:NULL config:config onStartDone:^(enum FlagshipResult result) {
        
        if (result == FlagshipResultReady){

          dispatch_async(dispatch_get_main_queue(), ^{
              
              /// update UI
              
               dispatch_async(dispatch_get_main_queue(), ^{

                    self.storeBtn.hidden = NO;

                   // Get the title for VIP user
                   NSString * title = [[Flagship sharedInstance] getModification:@"vipWording" defaultString:@"defaultTitle" activate:YES];

                   // Get the percent sale for VIP user
                   float percentSales = [[Flagship sharedInstance] getModification:@"percent" defaulfloat:10 activate:YES];
           });

         });
        }else{
            
            /// An error occurs or the SDK is disabled
        }
        
    }];
}


- (IBAction)goToStore{
    
    [self performSegueWithIdentifier:@"onShowStore" sender:nil];
}



@end
