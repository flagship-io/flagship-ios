# Introduction to iOS SDK

Welcome to the Flagship iOS SDK documentation!

The following documentataion helps you to run Flagship on your native ios app.

The SDK helps you :

 - Set a visitor id
 - Update visitor context
 - Allocate campaigns from the decision api
 - Get modifications
 - Launch campaigns
 - Send events

Feel free to [contact us](mailto:product@abtastycom) if you have any questions regarding this documentation.

## App prerequisites

* Your app must be a native app written in Swift or Objective C.

* FlagShip SDK supports at least ios 8.0+

* Swift Client application must use Swift 5 or higher

# Getting started
Our FlagShip is available for distribution through CocoaPods, Swift Package Manager or manual installation.


## Cocoapods

```ruby
target 'Your App' do
  use_frameworks!

  pod 'FlagShip'

  end
```
 
1. <a href='https://guides.cocoapods.org/'>Install CocoaPods.</a>

2. Open Terminal and browse to the directory that contains your project then, enter the following command: `pod init`

3. Open your Podfile and add the following line to the Podfile 

4. Run `pod install` from your Xcode project's base directory

5. Make sure you always open the Xcode workspace and not the project file when building your project

## Manual Installation

1. Download the frameWork  <a href='http://sdk.abtasty.com/ios/FlagShip.framework.zip'>FlagShip.</a>

2. In Finder, browse to the FlagShip.framework file and move it under your "Embedded Binaries" section in Xcode

3. Upon moving it, a popup is displayed: check "Copy items if needed".


### Apple Store Submission

```Swift
APP_PATH="${TARGET_BUILD_DIR}/${WRAPPER_NAME}"

# This script loops through the frameworks embedded in the application and
# removes unused architectures.
find "$APP_PATH" -name '*.framework' -type d | while read -r FRAMEWORK
do
FRAMEWORK_EXECUTABLE_NAME=$(defaults read "$FRAMEWORK/Info.plist" CFBundleExecutable)
FRAMEWORK_EXECUTABLE_PATH="$FRAMEWORK/$FRAMEWORK_EXECUTABLE_NAME"
echo "Executable is $FRAMEWORK_EXECUTABLE_PATH"

EXTRACTED_ARCHS=()

for ARCH in $ARCHS
do
echo "Extracting $ARCH from $FRAMEWORK_EXECUTABLE_NAME"
lipo -extract "$ARCH" "$FRAMEWORK_EXECUTABLE_PATH" -o "$FRAMEWORK_EXECUTABLE_PATH-$ARCH"
EXTRACTED_ARCHS+=("$FRAMEWORK_EXECUTABLE_PATH-$ARCH")
done

echo "Merging extracted architectures: ${ARCHS}"
lipo -o "$FRAMEWORK_EXECUTABLE_PATH-merged" -create "${EXTRACTED_ARCHS[@]}"
rm "${EXTRACTED_ARCHS[@]}"

echo "Replacing original executable with thinned version"
rm "$FRAMEWORK_EXECUTABLE_PATH"
mv "$FRAMEWORK_EXECUTABLE_PATH-merged" "$FRAMEWORK_EXECUTABLE_PATH"

done
```


<aside class="notice">
<b>FlagShip FrameWork is universal and BitCode supported</b> <br>
The universal framework for iOS contains architectures for simulators and devices. You will therefore be able to run your application on all devices and all iOS simulators.
</aside>

if  your app contains a universal framework, the App store will reject your app because of an unwanted architecture.
You need to add a new build phase, then select `Run Script` to add a new build step after `Embed frameworks`.
In the `Shell` field, enter the following script:

## Swift Package Manager (SPM)

You can search for **FlagShip** package on GitHub. Add your GitHub or GitHub Enterprise account in Xcode’s preferences, and a package repositorie appear as you type.

<div class="video-tuto"><img style="max-width:95%;" src="images/swiftPackage.gif"/></div>

</br>

For more information about Swift Package Manager click <a href="https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app">here</a> to see the apple Documentation


## Configure and Start FlagShip

### Start FlagShip in your App

```Swift
/// Import FlagShip
import FlagShip

        /// Set the context of VIP user 
        FlagShip.sharedInstance.context("isVip", true)

        FlagShip.sharedInstance.startFlagShip(environmentId:"your EnvId","userId") { (result) in
            
            // The state is ready , you can now use the FlagShip
            if result == .Ready {
                DispatchQueue.main.async {
                  // Update the UI
                }
            }else{

              /// An error occurs or the SDK is disabled
            }
        }
    }
    
```

```Objective-C
    // Define context
    [[FlagShip sharedInstance] updateContext:@{@"basketNumber":@200, @"isVipUser":@YES} sync:nil];
    
    
    [[FlagShip sharedInstance] startFlagShipWithEnvironmentId:@"your envId" :@""completionHandler:^(enum FlagShipResult result) {
        
        if (result == FlagShipResultReady){
            
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                     self.storeBtn.hidden = NO;
                    
                    // Get the title for VIP user
                    NSString * title = [[FlagShip sharedInstance] getModification:@"vipWording" defaultString:@"defaultTitle" activate:YES];
                    
                    // Get the percent sale for VIP user
                    float percentSales = [[FlagShip sharedInstance] getModification:@"percent" defaulfloat:10 activate:YES];
            });
        }

    }];
```

To run experiments with FlagShip, you will need to start the SDK. FlagShip uses a sharedInstance that can **activate** experiments and **track** events.

### `startFlagShip(environmentId:String, _ visitorId:String?, onFlagShipReady:@escaping(FlagShipResult)->Void)`


Parameter | Type | Required |Description
--------- | ------- |-------- |-----------
environmentId | String | Yes |Your environment id
visitorId | String |Yes | visitorId of the current visitor.
onFlagShipReady | block |Yes| The block to be invoked when the sdk is ready


<aside class="notice">
  If <code>visitorId</code> is <b>nil</b>, the sdk will automatically generate one.
</aside>



FlagShipResult indicate the state of the SDK   <b>Ready</b> | <b>NotReady</b>

<ul>
<li><b>Ready</b>    : <em>That mean the sdk is <b>ready</b> to use and you can get all modifications and send events</em></li>
<li><b>NotReady</b> : <em>That mean an error occure at the initialization for some reason (See the logs), only a default value are returned when you call getModification</em></li>
</ul>


As the SDK is asynchronous and runs in parallel, this method enables you to set a block which will be executed when the SDK is ready.

<aside class="notice">
<b> Remember to replace "your EnvId" with your own.</b>
</aside>

1. Navigate to **Parameters**->**Environment & Security**
2. Copy the environment ID

 <div class="video-tuto"><img style="max-width:95%;" src="images/envId.gif"></div><br>

### Example of Start



How to get the Welcome message for vip users:

This message will be delivered for the users that present a **vip** context only.
<div class="video-tuto"><img style="max-width:95%;" src="images/isVipTrue.png"></div> 

To get this message, you should set a context via the sdk:

<div class="video-tuto"><img style="max-width:95%;" src="images/setVip.png"></div>

Then you call the start function:

<div class="video-tuto"><img style="max-width:95%;" src="images/start.png"></div>

<aside class="notice">
Once the state is <b>Ready</b>, you have access to your modifications value <b>anywhere</b> in your project
</aside>


# Campaign integration

## Updating the user Context

The context is a Dictionary which define the current user of your app. This Dictionary is sent and **used by the Flagship decision API as targeting for campaign allocation**. For example, you could pass a VIP status in the context and then the decision API would enable or disable a specific feature flag.

<div class="video-tuto"><img style="max-width:95%;" src="images/isVip.png"></div>


### `FlagShip.sharedInstance.context("isVip", true)`


<aside class="notice">
Theses functions <b>update the visitor context value matching the given key</b>.
</aside>

<aside class="warning">
A new context value associated with this key will be created if there is no previous matching value.
</aside>




```Swift

// Here we set the context before starting the SDK
// Add basketNumber with value 10 in the user context
FlagShip.sharedInstance.context("basketNumber", 10)

// Add isVipUser with true value in the user context
FlagShip.sharedInstance.context("isVip", true) 

// Add name with value "alice" in the user context       
FlagShip.sharedInstance.context("name", "alice")

// Add valueKey with value 1.2 in the user context
FlagShip.sharedInstance.context("valueKey", 1.2)
        
// Start the SDK 
        FlagShip.sharedInstance.startFlagShip(environmentId:"your envId","userId") { (result) in
            
            // The state is ready , you can now use the FlagShip
            if result == .Ready {
                DispatchQueue.main.async {
                    
                    // Get title for banner
                    let title = FlagShip.sharedInstance.getModification("bannerTitle", defaultString: "More Infos",activate: true)
                    // Set the title
                    self.bannerBtn.setTitle(title, for: .normal)
                   }

            }else{
                
                /// An error occurs or the SDK is disabled
            }
        }
```

```Objective-C

 // Here we set the context before starting the SDK
 // Add basketNumber with value 10 in the user context
 // Add name  with value "alice" in the user context
 // Add valueKey with value 1.2 in the user context
    
  [[FlagShip sharedInstance] updateContext:@{@"basketNumber":@10, @"name":@"alice",@"valueKey": @1.2  } sync:^(enum FlagShipResult result) {
        
      if (result == FlagShipResultUpdated) {
            
                        NSString * title = [[FlagShip sharedInstance] getModification:@"bannerTitle" defaultString:@"More Infos" activate:YES];

      }
  }];



```
### The sdk provides some methods for pushing new context values:

* Add a Boolean Value to the Context user:</br>
**`func context(_ key:String,  _ boolean:Bool)`**

* Add a  Double Value to the context user:</br>
**`func context(_ key:String,  _ double:Double)`**

* Add a  String Value to the context user:</br>
**`func context(_ key:String,  _ text:String)`**

* Add a Float Value to the context user:</br>
**`func context(_ key:String,  _ float:Float)`**

</br>

Parameter | Type |Required|Description
--------- | ------- |-------|-----------
key | String | Yes |key to associate with the following value
value | String, Double, Boolean, FLoat|Yes| the value to add in the context



## Update context with predefined keys of context

**`func updateContextWithPreConfiguredKeys(_ configuredKey:FSAudiences, value:Any,sync:((FlagShipResult)->Void)?)`**


Parameter | Type |Required|Description
--------- | ------- |-------|-----------
configuredKey | FSAudiences | Yes |The values defined in an enumeration  <b>FSAudiences</b>
value | String, Double, Boolean, FLoat|Yes| the value to add in the context
sync | block |Yes| The block to be invoked when the sdk is ready

```Swift 

// Update the context with several keys
FlagShip.sharedInstance.updateContext([FSAudiences.LOCATION_CITY.rawValue:"paris",
                                      FSAudiences.LOCATION_COUNTRY.rawValue:"France",
                                      FSAudiences.LOCATION_REGION.rawValue:"ile de france"]) { (result) in

                                     }
        
// update context with pre configured key
FlagShip.sharedInstance.updateContextWithPreConfiguredKeys(.LOCATION_REGION, value: "ile de france") { (result) in

  // Adapt your modification after updating the context

}

```
```Objective-C

    /// See the FSAudiences enum , to get raw value for keys of context you want to update

    [[FlagShip sharedInstance] updateContext:@{@"sdk_city":@"paris",@"sdk_region":@"ile de france",@"sdk_country":@"france"} sync:^(enum FlagShipResult result) {
        
         // Adapt your modification after updating the context
    }];
    

```

When starting the SDK, it loads **automatically** a set of predefined keys (Device type, ios version, etc). That keys will help you to filter and analyze your report.

The list of predefined keys:

<table class="table table-bordered table-striped">
    <thead>
    <tr>
        <th style="width: 100px;">Pre defined Key</th>
        <th style="width: 50px;">Type</th>
        <th style="width: 250px;">Auto set by the Sdk</th>
        <th>description</th>
    </tr>
    </thead>
    <tbody>
        <tr>
          <td><b>FIRST_TIME_INIT</b></td>
          <td>boolean</td>
          <td>Yes</td>
          <td>First init of the app</td>
        </tr>
        <tr>
          <td><b>DEVICE_LOCALE</b></td>
          <td>String</td>
          <td>Yes</td>
          <td>Language of the device</td>
        </tr>
        <tr>
          <td><b>DEVICE_MODEL</b></td>
          <td>String</td>
          <td>Yes</td>
          <td>Tablette / Mobile</td>
        </tr>
        <tr>
          <td><b>DEVICE_TYPE</b></td>
          <td>String</td>
          <td>Yes</td>
          <td>Model of the device</td>
        </tr>
        <tr>
          <td><b>LOCATION_CITY</b></td>
           <td>String</td>
          <td>No</td>
          <td>City geolocation</td>
        </tr>
        <tr>
          <td><b>LOCATION_REGION</b></td>
           <td>String</td>
          <td>No</td>
          <td>Region geolocation</td>
        </tr>
        <tr>
          <td><b>LOCATION_COUNTRY</b></td>
           <td>String</td>
          <td>No</td>
          <td>Country geolocation</td>
        </tr>
        <tr>
          <td><b>LOCATION_LAT</b></td>
           <td>Double</td>
          <td>No</td>
          <td>Current Latitude</td>
        </tr>
        <tr>
          <td><b>LOCATION_LONG</b></td>
           <td>Double</td>
          <td>No</td>
          <td>Current Longitude</td>
        </tr>
        <tr>
          <td><b>IP</b></td>
           <td>String</td>
          <td>No</td>
          <td>IP of the device</td>
        </tr>
        <tr>
          <td><b>OS_NAME</b></td>
           <td>String</td>
          <td>Yes</td>
          <td>iOS</td>
        </tr>
        <tr>
          <td><b>OS_VERSION</b></td>
           <td>String</td>
          <td>Yes</td>
          <td>ios version</td>
        </tr>
        <tr>
          <td><b>CARRIER_NAME</b></td>
           <td>String</td>
          <td>Yes</td>
          <td>Name of the operator</td>
        </tr>
        <tr>
          <td><b>DEV_MODE</b></td>
           <td>Boolean</td>
          <td>No</td>
          <td>Is the app in debug mode?</td>
        </tr>
          <tr>
          <td><b>INTERNET_CONNECTION</b></td>
           <td>String</td>
          <td>No</td>
          <td>What is the internet connection</td>
        </tr>        <tr>
          <td><b>APP_VERSION_NAME</b></td>
           <td>String</td>
          <td>No</td>
          <td>Version name of the app</td>
        </tr>        <tr>
          <td><b>APP_VERSION_CODE</b></td>
           <td>String</td>
          <td>No</td>
          <td>Version code of the app</td>
        </tr>
                </tr>        <tr>
          <td><b>INTERFACE_NAME</b></td>
           <td>String</td>
          <td>No</td>
          <td>Name of the interface</td>
        </tr>        </tr>        <tr>
          <td><b>FLAGSHIP_VERSION</b></td>
           <td>String</td>
          <td>No</td>
          <td>Version of the Flagship SDK</td>
        </tr>
    </tbody>
</table>


<aside class="notice">
To overwrite the pre loaded keys, use the same function updateContextWithPreConfiguredKeys
</aside>


  <div class="video-tuto"><img style="max-width:95%;" src="images/preDefineKey.png"></div><br>

  In this example you can see the pre defined key **DEVICE_TYPE** to filter your report



## Synchronizing campaigns

Synchronizing campaign modifications allows you to **automatically** call the Flagship decision API, which makes the allocation according to the user context and gets all their modifications. All the modifications returned by the API are stored in the SDK and are updated asynchronously when syncCampaignModifications() is called.

**`func updateContext(_ contextvalues:Dictionary<String,Any>, sync:((FlagShipResult)->Void)?)`**

```Swift

        /// Update the context when basket value change
        FlagShip.sharedInstance.updateContext(["basketValue":120]) { (result) in
            
            if result == .Updated{
                
                // Update the UI for users that have basket over or equal 100
                if (FlagShip.sharedInstance.getModification("freeDelivery", defaultBool: false, activate: true)){
                    
                    DispatchQueue.main.async {
                        
                        /// Show your message for free delivery
                        
                    }
                }
            }
        }
```

```Objective-C

// Here, for example, update VIP user info and adapt the UI...

// update isVipUser with false value in the user context
    [[FlagShip sharedInstance] updateContext:@{@"isVipUser":@NO} sync:^(enum FlagShipResult state) {
         
      // In this block you will have new values updated for non VIP users

      dispatch_async(dispatch_get_main_queue(), ^{
            
         // do work here to Usually to update the User Interface
         // Get title for banner
         NSString * title = [[FlagShip sharedInstance] getModification:@"bannerTitle" defaultString:@"More Infos" activate:YES];
         // Set the tile
         
        });
     }];
```


  Parameter | Type | Description
  --------- | -------|-----------
  contextValues | Dictionary | represent keys/Value for the context 
  sync | Block to execute once the sync is completed

  FlagShipResult indicate the state of the SDK   <b>Updated</b> | <b>NotReady</b>

<ul>
<li><b>Updated</b>    : <em>That mean the sdk is <b>Updated</b> you can get all new modifications according to contextValues</em></li>
<li><b>NotReady</b>   : <em>That mean an error occure at the update for some reason (See the logs), only previous modifications before the update still available </em></li>
</ul>


<aside class="notice">
Once the new values given by the decision API are <b>updated</b>, this block is executed.
</aside>

### Example for updating context

How to manage **Free Shipping threshold**. In our case the threshold is **100$**
<div class="video-tuto"><img style="max-width:95%;" src="images/basketValue.png"></div><br>

In your code, just call this function:

<div class="video-tuto"><img style="max-width:95%;" src="images/updateFunc.png"></div>

</br>

This function will ask the decision API and get the new modifications **according** to context passed as parameters 

Once update is done, you can display the message for the free delivery, as described in the example above.


## Retrieving modifications and Activation

Now the campaign has been **allocated and synchronized** , all the modifications are stored on the SDK. You can use the following functions to retrieve them:

* Get Modification for boolean key:</br>
**`func getModification(_ key:String, defaultBool:Bool, activate:Bool) -> Bool`**

* Get Modification for String key:</br>
**`func getModification(_ key:String, defaultString:String, activate:Bool) -> String`**

* Get Modification for Double key:</br>
**`func getModification(_ key:String, defaultDouble:Double, activate:Bool) -> Double`**

* Get Modification for Float key:</br>
**`func getModification(_ key:String, defaulfloat:Float, activate:Bool) -> Float`**

* Get Modification for Int key:</br>
**`func getModification(_ key:String, defaultInt:Int, activate:Bool) -> Int`**


<aside class="warning">
If the decision API doesn't return any value for a key, the SDK will <b>display</b> the default value.
</aside>

Parameter | Type |Required|Description
--------- | ------- |------- |-----------
key | String, Boolean, Int, Float, Double |Yes| key associated with the modification.
default | String, Boolean, Int, Float, Double |Yes| default value returned when the key **doesn't match any modification value**.
activate | Boolean |No| **false by default**  Set this parameter to **true** to automatically report on our server that the current visitor has seen this modification. If false, call the [activateModification()](http://localhost:8080/ios/v1.x/?Swift#activating-modifications) later.


An example of keys values defined in the **variation 1**

<div class="video-tuto"><img style="max-width:95%;" src="images/keyValue.png"></a></div>

<br>

How to gets values:
<div class="video-tuto"><img style="max-width:95%;" src="images/getValues.gif"></a></div>




```Swift
// Retreive modification and activate
let title = FlagShip.sharedInstance.getModification("bannerTitle", defaultString: "More Infos", activate: true)

```

```Objective-C

// Retreive modification and activate
 NSString * title = [[FlagShip sharedInstance] getModification:@"bannerTitle" defaultString:@"More Infos" activate:YES];

```

## Activating modifications

Once a modification has been **printed** on the screen for a user (and if your `activate` parameter was `false` in the [`getModification` method](http://localhost:8080/ios/v1.x/?Swift#retrieving-modifications-and-activation)), **you must send an activation** event to tell Flagship that the user has seen this specific variation.

```Swift
    
// Activate modification to tell Flagship that the user has seen this specific variation
    
FlagShip.sharedInstance.activateModification(key: "cta_text")

```
```Objective-C
        
// Activate modification to tell Flagship that the user has seen this specific variation
    
[[FlagShip sharedInstance] activateModificationWithKey:@"cta_text"];

```

**`func activateModification(key:String)`**

Parameter | Type |Required| Description
--------- | ------- |-----|-----------
key | String |Yes|key which identifies the modification

<aside class="warning">
If the key doesn't exist, the <b>activate is not sent</b>. 
</aside>

Get Modification and activate it manually
<div class="video-tuto"><img style="max-width:95%;" src="images/getWithoutActivate.gif"></a></div>

# Hit Tracking

This section helps you track your users and learn how to build hits in order to feed campaign goals

The types of Hits are as follows: 

* Page
* Transaction
* Item
* Event. 

**They must all be sent with the following function:**

`func sendTracking<T: FSTrackingProtocol>(_ event:T)`

## Page

```Swift

// Usage: usually we send this hit when changing screen in the app
let eventPage = FSPageTrack("loginScreen")
FlagShip.sharedInstance.sendTracking(eventPage)

```

```Objective-C

// Usage: usually we send this hit when changing screen in the app
// Create page event
FSPageTrack * eventPage =  [[FSPageTrack alloc] init:@"loginScreen"];

// Send Event
[[FlagShip sharedInstance] sendPageEvent:eventPage];

```

This hit should be sent each time a visitor arrives on a new interface.

**FSPageTrack** class represents this hit and requires interfaceName as a string parameter

**`init(_ interfaceName:String)`**

Parameter | Type | Required | Description
--------- | ------- | ----------- | ----------
interfaceName | String| Yes | Interface name


## Transaction

Hit to send when a user completes a Transaction
**FSTransactionTrack** represents it and requires a unique `transactionId` and `affiliation` name. `affiliation` is the name of the transaction goal.


```Swift

// The affiliation is the name of transaction that should appear in the report

let transacEvent:FSTransactionTrack = FSTransactionTrack(transactionId:"transacId", affiliation: "BasketTransac")
transacEvent.currency = "EUR"
transacEvent.itemCount = 0
transacEvent.paymentMethod = "PayPal"
transacEvent.ShippingMethod = "Fedex"
transacEvent.tax = 2.6
transacEvent.revenue = 15
transacEvent.shipping = 3.5
FlagShip.sharedInstance.sendTracking(transacEvent)

```

```Objective-C

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
[[FlagShip sharedInstance] sendTransactionEvent:transacEvent];

```

**`init(transactionId:String, affiliation:String)`**


Parameter | Type | Required | Description
--------- | ------- | ----------- | -------
transactionId | String | required | Transaction unique identifier.
affiliation | String | required | Transaction name. Name of the goal in the reporting.
revenue | Float | optional | Total revenue associated with the transaction. This value should include any shipping or tax costs.
shipping | Float | optional | Specifies the total shipping cost of the transaction.
tax | Float | optional | Specifies the total taxes of the transaction.
currency | String | optional | Specifies the currency used for all transaction currency values. Value should be a valid ISO 4217 currency code.
paymentMethod | String | optional | Specifies the payment method for the transaction.
ShippingMethod | String | optional | Specifies the shipping method of the transaction.
itemCount | Int | optional | Specifies the number of items for the transaction.
couponCode | String | optional | Specifies the coupon code used by the customer for the transaction.

## Item

```Swift

// Item usually represents a product. An item must be associated with a transaction event.
    
let itemEvent:FSItemTrack = FSItemTrack(transactionId: transacId, name: "MicroTransac", price: 1, quantity: 1, code: "CodeItem", category: "category")
ABFlagShip.sharedInstance.sendTracking(itemEvent)

```


```Objective-C

// Item usually represents a product. An item must be associated with a transaction event.

// Create item event
FSItemTrack * itemEvent = [[FSItemTrack alloc] initWithTransactionId:@"transacId" name:@"MicroTransac" price:@1 quantity:@1 code:@"code" category:@"category"];

// Send item event
[[FlagShip sharedInstance] sendItemEvent:itemEvent];
    
```


Hit to send an item with a transaction. It must be sent after the corresponding transaction.

<b>FSItemTrack</b> represents this hit and requires transactionId and product name


**`init(transactionId:String, name:String)`**

Parameter | Type | Required | Description
--------- | ------- | ----------- | -------
transactionId | String | required | Transaction unique identifier.
name | String | required | Product name.
price | Float | optional | Specifies the item price.
code | String | optional | Specifies the item code or SKU.
category | String | optional | Specifies the item category.
quantity | Int | optional | Specifies the item quantity

## Event

```Swift

// Create event for any user action
// The event action is the name to display in the report

let actionEvent:FSEventTrack = FSEventTrack(eventCategory: FSCategoryEvent.Action_Tracking, eventAction: "cta_Shop")
actionEvent.label = "cta_Shop_label"
actionEvent.eventValue = 1
actionEvent.interfaceName = "HomeScreen"

// Send Event Tracking
FlagShip.sharedInstance.sendTracking(actionEvent)

```


```Objective-C

// Create event for any user action
// The event action is the name to display in the report
FSEventTrack * actionEvent = [[FSEventTrack alloc] initWithEventCategory:FSCategoryEventAction_Tracking eventAction:@"cta_Shop"];
actionEvent.label = @"cta_Shop_label";
actionEvent.eventValue = @1;
actionEvent.interfaceName = @"HomeScreen";
[[FlagShip sharedInstance] sendEventTrack:actionEvent];
    
```

 
Hit which represents an event. It can be anything you want: for example a click on an Add to Cart button or a newsletter subscription.

<**FSEventTrack**  represents this hit and requires a category event and action name string

**FSCategoryEvent** can be `Action_Tracking`  or  `User_Engagement`

`init(eventCategory:FSCategoryEvent, eventAction:String)`

Parameter | Type | Required | Description
--------- | ------- | ----------- | ----- 
category | FSCategoryEvent | required | category of the event (Action_Tracking or User_Engagement).
action | String | required |  name of the event.
label | String | optional | description of the event.
eventValue | Number | optional | value of the event, must be non-negative.

## Common parameter for Hits

```Swift
// Create event
let eventPage = FSPageTrack("loginScreen")
// Fill data for event page   
eventPage.userIp = "168.192.1.0"
eventPage.sessionNumber = 12
eventPage.screenResolution = "750 x 1334"
eventPage.screenColorDepth = "#fd0027"
eventPage.sessionNumber = 1
eventPage.userLanguage = "fr"
eventPage.sessionEventNumber = 2
// Send Event
FlagShip.sharedInstance.sendTracking(eventPage)

```

```Objective-C
// Create event
FSPageTrack * eventPage =  [[FSPageTrack alloc] init:@"loginScreen"];
// Fill data for event page
eventPage.userIp = @"168.192.1.0";
eventPage.sessionNumber = @12;
eventPage.screenResolution = @"750 x 1334";
eventPage.screenColorDepth = @"#fd0027";
eventPage.sessionNumber = @1;
eventPage.userLanguage = @"fr";
eventPage.sessionEventNumber = @2;
[[FlagShip sharedInstance] sendPageEvent:eventPage];

```
These parameters can be sent with any type of hit.

 Parameter | Type | Description
--------- | ------- | -----------
userIp | String | **optional** optional User IP
screenResolution | String | **optional** Screen Resolution.
userLanguage | String | **optional**  User Language 
currentSessionTimeStamp | Int64 | **optional** Current Session Timestamp
sessionNumber | Int | **optional** Session Number


# Logs
Logs are **enabled** by default. If you want to stop logs, set the “enableLogs” to false


# Release

Current version 1.1.0

- Add Pre defined context keys
- Add Swift Package Manager
- Include the Environment id in the start function
- Change the name of ABFlagShip to **FlagShip**
- Fix bugs


```Swift
// Stop Logs displaying
FlagShip.sharedInstance.enableLogs = false
```

```Objective-C
// Stop Logs displaying
[[ABFlagShip sharedInstance] setEnableLogs:NO];

```
# Reference

[ios reference](ios-reference)

# Sources

Sources of the FlagShip and samples are available at :
https://github.com/abtasty/flagship-ios