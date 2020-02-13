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
    [[Flagship sharedInstance] updateContext:@{@"basketNumber":@200, @"isVipUser":@YES} sync:nil];
    
    
    [[Flagship sharedInstance] startFlagShipWithEnvironmentId:@"your envId" :@""completionHandler:^(enum FlagShipResult result) {
        
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
    
    
    
    
    [[Flagship sharedInstance] updateContext:@{@"basketNumber":@10, @"name":@"alice",@"valueKey": @1.2  } sync:^(enum FlagShipResult result) {
        
        if (result == FlagShipResultUpdated) {
            
            NSString * title = [[Flagship sharedInstance] getModification:@"bannerTitle" defaultString:@"More Infos" activate:YES];

        }
    }];
    
    
    [[Flagship sharedInstance] updateContext:@{@"sdk_city":@"paris",@"sdk_region":@"ile de france",@"sdk_country":@"france"} sync:^(enum FlagShipResult result) {
        
    }];
    
  
    

    [[Flagship sharedInstance] updateContext:@{@"isVipUser":@NO} sync:^(enum FlagShipResult state) {
         
      // In this block you will have new values updated for non VIP users

      dispatch_async(dispatch_get_main_queue(), ^{
            
         // do work here to Usually to update the User Interface
         // Get title for banner
         NSString * title = [[Flagship sharedInstance] getModification:@"bannerTitle" defaultString:@"More Infos" activate:YES];
         // Set the tile
         
        });
     }];
    
    [[Flagship sharedInstance] activateModificationWithKey:@"cta_text"];

    
    
}



- (IBAction)goToStore{
    
    [self performSegueWithIdentifier:@"onShowStore" sender:nil];
}



@end
