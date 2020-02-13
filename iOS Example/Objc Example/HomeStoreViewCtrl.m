//
//  HomeStoreViewCtrl.m
//  objcExample
//
//  Created by Adel on 25/10/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

#import "HomeStoreViewCtrl.h"

@import FlagShip;

@interface HomeStoreViewCtrl ()

@end

@implementation HomeStoreViewCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}



- (IBAction)startFlagShip{
    
    
    // Define context
    [[FlagShip sharedInstance] updateContext:@{@"basketNumber":@200, @"isVipUser":@YES} sync:nil];
    
    // Start FlagShip
    [[FlagShip sharedInstance] startFlagShip:@"alice" onFlagShipReady:^(NSInteger state) {
        
            dispatch_async(dispatch_get_main_queue(), ^{
                
                 self.storeBtn.hidden = NO;
                
                // Get the title for VIP user
                NSString * title = [[FlagShip sharedInstance] getModification:@"vipWording" defaultString:@"defaultTitle" activate:YES];
                
                // Get the percent sale for VIP user
                float percentSales = [[FlagShip sharedInstance] getModification:@"percent" defaulfloat:10 activate:YES];
        });
    }];
}



- (IBAction)goToStore{
    
    [self performSegueWithIdentifier:@"onShowStore" sender:nil];
}



@end
