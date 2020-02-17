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
    [[Flagship sharedInstance] updateContext:@{@"basketNumber":@200, @"isVipUser":@YES} sync:nil];
    
    
    [[Flagship sharedInstance] startFlagShipWithEnvironmentId:@"bkk9glocmjcg0vtmdlng" :@"alias"completionHandler:^(enum FlagShipResult result) {
        
        if (result == FlagShipResultReady){
            
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                     self.storeBtn.hidden = NO;
                    
                    // Get the title for VIP user
                    NSString * title = [[Flagship sharedInstance] getModification:@"vipWording" defaultString:@"defaultTitle" activate:YES];
                    
                    // Get the percent sale for VIP user
                    float percentSales = [[Flagship sharedInstance] getModification:@"percent" defaulfloat:10 activate:YES];
            });
        }

    }];
    
    
}



- (IBAction)goToStore{
    
    [self performSegueWithIdentifier:@"onShowStore" sender:nil];
}



@end
