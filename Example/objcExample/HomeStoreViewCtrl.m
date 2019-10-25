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
    
    // update context
    [[ABFlagShip sharedInstance] updateContext:@{@"isVipUser":@YES} sync:nil];
    
    // Start FlagShip
    [[ABFlagShip sharedInstance] startFlagShip:@"alice" onFlagShipReady:^(NSInteger state) {
        
            dispatch_async(dispatch_get_main_queue(), ^{
                
                 self.storeBtn.hidden = NO;
        });
    }];
}



- (IBAction)goToStore{
    
    [self performSegueWithIdentifier:@"onShowStore" sender:nil];
}



@end
