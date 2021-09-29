//
//  StoreViewController.m
//  objcExample
//
//  Created by Adel on 25/10/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

#import "StoreViewController.h"

@import Flagship;

@interface StoreViewController ()

@end

@implementation StoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set Message Label
    msgLabel.text =  [[Flagship sharedInstance] getModification:@"cta_text" defaultString:@"Default" activate:YES];
    
    
    /// Get modification info
    NSDictionary * dico =  [[Flagship sharedInstance] getModificationInfoWithKey:@"btn-color"];
    
    if (dico){
        /// Get campaignid
        NSString * campaignId = [dico valueForKey:@"campaignId"];
        /// Get variation group id
        NSString * variationGroupId = [dico valueForKey:@"variationGroupId"];
        /// Get variation id
        NSString * variationId = [dico valueForKey:@"variationId"];
        
        NSLog(@" %@ , %@, %@", campaignId, variationGroupId, variationId);

    }else{
        
        NSLog(@"The key modification doesn't exist.");
    }
}




- (IBAction)cancel{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


// Send All Event Possible
- (IBAction)sendEvent{
    
   
    
    // Send Page
    [[Flagship sharedInstance] sendScreenEvent: [[FSScreen alloc] init:@"StorePage"]];
    

    // Send Item
    FSItem * itemTrack = [[FSItem alloc] initWithTransactionId:@"Ttransac" name:@"nameTransac" code:@""];
    itemTrack.price = @0;
    itemTrack.quantity = @12;
    [[Flagship sharedInstance] sendItemEvent:itemTrack];
    
    
    // Send Transaction
    FSTransaction * transac = [[FSTransaction alloc] initWithTransactionId:@"transacObjc" affiliation:@"affilObjc"];
    transac.userIp  = @"1.1.1.1";
    [[Flagship sharedInstance] sendTransactionEvent:transac];
    
    
    
    
    // Send Event Track
    [[Flagship sharedInstance] sendEventTrack:[[FSEvent alloc] initWithEventCategory:FSCategoryEventAction_Tracking eventAction:@"aaa"]];

 }

@end
