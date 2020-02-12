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
    
    
    /// Here we set the context before start the FlagShip
    // Add basketNumber with value 10 in the user context
    // Add name  with value "alice" in the user context
    // Add valueKey with value 1.2 in the user context
    
    [[ABFlagShip sharedInstance] updateContext:@{@"basketNumber":@10, @"name":@"alice",@"valueKey": @1.2  } sync:nil];
    
    [[ABFlagShip sharedInstance] startFlagShip:@"idVisitor" onFlagShipReady:^(NSInteger state) {
        
         // Get title for banner
        NSString * title = [[ABFlagShip sharedInstance] getModification:@"bannerTitle" defaultString:@"More Infos" activate:YES];
    }];
    
    
    //    Here, for example, update VIP user info and adapt the UI...
    //
    //    update isVipUser with false value in the user context
    [[ABFlagShip sharedInstance] updateContext:@{@"isVipUser":@NO} sync:^(enum FlagshipState state) {
        
        // In this block you will have new values updated for non VIP users
        
       dispatch_async(dispatch_get_main_queue(), ^{
           
           // do work here to Usually to update the User Interface
           // Get title for banner
           NSString * title = [[ABFlagShip sharedInstance] getModification:@"bannerTitle" defaultString:@"More Infos" activate:YES];
           // Set the tile
           UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
           [btn setTitle:title forState:UIControlStateNormal];
       });
    }];
    
    
//ABFlagShip.sharedInstance.getModification("bannerTitle", defaultString: "More Infos", activate: true)
    
    // Retreive modification and activate
    NSString * title = [[ABFlagShip sharedInstance] getModification:@"bannerTitle" defaultString:@"More Infos" activate:YES];
    
    
    // Activate modification to tell Flagship that the user has seen this specific variation
    
    [[ABFlagShip sharedInstance] activateModificationWithKey:@"cta_text"];
    
//    // Create page event
//    FSPageTrack * eventPage =  [[FSPageTrack alloc] init:@"loginScreen"];
//    // Send Event
//    [[ABFlagShip sharedInstance] sendPageEvent:eventPage];
    
    
    // The affiliation is the name of transaction that should appear in the report
    // Create the transaction event
    FSTransactionTrack * transacEvent =  [[FSTransactionTrack alloc] initWithTransactionId:@"transacId" affiliation:@"BasketTransac"];
    transacEvent.currency = @"EUR";
    transacEvent.itemCount = 0;
    transacEvent.paymentMethod = @"PayPal";
    transacEvent.ShippingMethod = @"Fedex";
    transacEvent.tax = @2.6;
    transacEvent.revenue = @15;
    transacEvent.shipping = @3.5;
    // Send the transaction event
    [[ABFlagShip sharedInstance] sendTransactionEvent:transacEvent];
    
    
    // Create item event
    FSItemTrack * itemEvent = [[FSItemTrack alloc] initWithTransactionId:@"transacId" name:@"MicroTransac" price:@1 quantity:@1 code:@"code" category:@"category"];
    // Send item event
    [[ABFlagShip sharedInstance] sendItemEvent:itemEvent];
    
    
    // Create event for any user action
    // The event action you give here is the name who should be displayed on the report
    FSEventTrack * actionEvent = [[FSEventTrack alloc] initWithEventCategory:FSCategoryEventAction_Tracking eventAction:@"cta_Shop"];
    actionEvent.label = @"cta_Shop_label";
    actionEvent.eventValue = @1;
    actionEvent.interfaceName = @"HomeScreen";
    [[ABFlagShip sharedInstance] sendEventTrack:actionEvent];
    
    //// create event
    FSPageTrack * eventPage =  [[FSPageTrack alloc] init:@"loginScreen"];
    //// fill data for event page
    eventPage.userIp = @"168.192.1.0";
    eventPage.sessionNumber = @12;
    eventPage.screenResolution = @"750 x 1334";
    eventPage.screenColorDepth = @"#fd0027";
    eventPage.sessionNumber = @1;
    eventPage.userLanguage = @"fr";
    eventPage.sessionEventNumber = @2;
    [[ABFlagShip sharedInstance] sendPageEvent:eventPage];
    
    [[ABFlagShip sharedInstance] setEnableLogs:NO];
}

//
//// create event
//let eventPage = FSPageTrack("loginScreen")
//// fill data for event page
//eventPage.userIp = "168.192.1.0"
//eventPage.sessionNumber = 12
//eventPage.screenResolution = "750 x 1334"
//eventPage.screenColorDepth = "#fd0027"
//eventPage.sessionNumber = 1
//eventPage.userLanguage = "fr"
//eventPage.sessionEventNumber = 2
//// Send Event
//ABFlagShip.sharedInstance.sendTracking(eventPage)
 

- (IBAction)goToStore{
    
    [self performSegueWithIdentifier:@"onShowStore" sender:nil];
}



@end
