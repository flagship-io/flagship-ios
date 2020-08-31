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
    
    
   
    [[Flagship sharedInstance] synchronizeModificationsWithCompletion:^( FlagshipResult st) {
        
        
    }];
    
    
    [[Flagship sharedInstance] updateContext:@{@"Boolean_Key":@YES,@"String_Key":@"june",@"Number_Key":@200}];
    
    [[Flagship sharedInstance] startFlagShipWithEnvironmentId:@"bkk9glocmjcg0vtmdlng" :NULL completionHandler:^( FlagshipResult result) {
        
        if (result == FlagshipResultReady){
            
               [self docMe];
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


- (void)docMe{
    
    
    /// Update context
    [[Flagship sharedInstance] updateContext:@{@"basketNumber":@10, @"name":@"alice",@"valueKey": @1.2  }];
    
    /// Synchronize modfication
    [[Flagship sharedInstance] synchronizeModificationsWithCompletion:^(enum FlagshipResult result) {
        if (result == FlagshipResultUpdated){
            
            /// Update UI ....
            NSString * title = [[Flagship sharedInstance] getModification:@"bannerTitle" defaultString:@"More Infos" activate:YES];
        }
        
    }];
    
    
    
    
    // Here, for example, update VIP user info and adapt the UI...
   
    // update isVipUser with false value in the user context
    [[Flagship sharedInstance] updateContext:@{@"isVipUser":@NO}];
    
    /// Synchronize modfication
    [[Flagship sharedInstance] synchronizeModificationsWithCompletion:^(enum FlagshipResult result) {
        
        if (result == FlagshipResultUpdated){
            
            dispatch_async(dispatch_get_main_queue(), ^{
                  
               // do work here to Usually to update the User Interface
               // Get title for banner
               NSString * title = [[Flagship sharedInstance] getModification:@"bannerTitle" defaultString:@"More Infos" activate:YES];
               // Set the tile
               
              });
        }
        
    }];
    
    
    
    // Retrieve modification and activate
    NSString * title = [[Flagship sharedInstance] getModification:@"bannerTitle" defaultString:@"More Infos" activate:YES];
    
    
    [[Flagship sharedInstance] activateModificationWithKey:@"cta_text"];
    
    
    FSPage * eventPage =  [[FSPage alloc] init:@"loginScreen"];

    // Send Event
    [[Flagship sharedInstance] sendPageEvent:eventPage];



    FSTransaction * transacEvent =  [[FSTransaction alloc] initWithTransactionId:@"transacId" affiliation:@"BasketTransac"];
    transacEvent.currency = @"EUR";
    transacEvent.itemCount = 0;
    transacEvent.paymentMethod = @"PayPal";
    transacEvent.shippingMethod = @"Fedex";
    transacEvent.tax = @2.6;
    transacEvent.revenue = @15;
    transacEvent.shipping = @3.5;
    // Send the transaction event
    [[Flagship sharedInstance] sendTransactionEvent:transacEvent];
    
    
    
    
    // Create item event
    FSItem * itemhit = [[FSItem alloc] initWithTransactionId:@"transacId" name:@"MicroTransac" code:@"codeSku"];
    /// Set Price
    itemhit.price = @20;
    /// Set category
    itemhit.category = @"category";
    /// Set quantity
    itemhit.quantity = @1;

    // Send item event
    [[Flagship sharedInstance] sendItemEvent:itemhit];
    
    
    
    
    // Create event for any user action
    // The event action is the name to display in the report
    FSEvent * actionEvent = [[FSEvent alloc] initWithEventCategory:FSCategoryEventAction_Tracking eventAction:@"cta_Shop"];
    actionEvent.label = @"cta_Shop_label";
    actionEvent.eventValue = @1;
    actionEvent.interfaceName = @"HomeScreen";
    [[Flagship sharedInstance] sendEventTrack:actionEvent];
    
    
    // Create event
    FSPage* eventPagev =  [[FSPage alloc] init:@"loginScreen"];
    // Fill data for event page
    eventPage.userIp = @"168.192.1.0";
    eventPage.sessionNumber = @12;
    eventPage.screenResolution = @"750 x 1334";
    eventPage.screenColorDepth = @"#fd0027";
    eventPage.sessionNumber = @1;
    eventPage.userLanguage = @"fr";
    eventPage.sessionEventNumber = @2;
    [[Flagship sharedInstance] sendPageEvent:eventPagev];
    
    [[Flagship sharedInstance] setEnableLogs:NO];
    
}


- (IBAction)goToStore{
    
    [self performSegueWithIdentifier:@"onShowStore" sender:nil];
}



@end
