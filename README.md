## How To Get Started

- [Download FlagShip](https://gitlab.com/abtasty/mobile/flagship-ios/-/archive/master/flagship-ios-master.zip) and try out the iPhone example apps.
- See the ["Configure FlagShip"](https://gitlab.com/abtasty/mobile/flagship-ios#configure-flagship) and make sure to remplace <b>FlagShipEnvId</b> with your Environment id provided by Flagship
- Read the ["Getting started" guide](https://gitlab.com/abtasty/mobile/flagship-ios/blob/master/README.md#getting-started)

# Introduction

Welcome to the FlagShip iOS documentation!

The Flagship SDK is an iOS framework whose purpose is to help you run Flagship campaigns on your native ios app.

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

# Getting started
FlagShip is available for distribution through Pods or manual installation.
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

## Apple Store Submission

```swift
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

If your app contains a universal framework, the App store will reject your app because of an unwanted architecture.
You need to add a new build phase, then select `Run Script` to add a new build step after `Embed frameworks`.
In the `Shell` field, enter the following script:


## Configure and Start FlagShip

### Configure FlagShip

In the The Information Property List, add new <b>FlagShipEnvId</b> key and set the value of your Environment id provided by Flagship

![alt text](images/infoPlist.png)

<aside class="notice">
You can find your environment id in the parameters\integration section of your Flagship account.
</aside>

### Start FlagShip in your App

> Call the *startFlagShip* function from the class *ABFlagShip* to start the SDK

```swift

import FlagShip

// Define context
ABFlagShip.sharedInstance.context("basketNumber", numberValue)
ABFlagShip.sharedInstance.context("isVipUser", true)

// Start FlagShip
ABFlagShip.sharedInstance.startFlagShip("alice") { (state) in
DispatchQueue.main.async {
// Get the title for VIP user
let titleForVip = ABFlagShip.sharedInstance.getModification("vipWording", defaultString:"defaultTitle", activate: true)

// Get the percent sale for VIP user
let percentSales = ABFlagShip.sharedInstance.getModification("percent", defaulfloat:10, activate: true)
}

}

```

To run experiments with ABFlgShip, you will need to start the SDK. ABFlgShip uses a sharedInstance that can activate experiments and track events.
To do so, just call the `startFlagShip` function in the ABFlgShip class located in the ABFlgShipSdk.framework frameWork.

`func startFlagShip(_ visitorId:String?, onFlagShipReady:@escaping(FlagshipState)->Void)`

Parameter | Type | Description
--------- | ------- | -----------
visitorId | NSString | optional visitorId of the current visitor.
onFlagShipReady | block | The block to be invoked when the sdk is ready

FlagshipState indicate the state of the SDK   <b>Ready</b> | <b>NotReady</b> | <b>Updated</b>

As the SDK is asynchronous and runs in parallel, this method enables you to set a block which will be executed when the SDK is ready.

# Campaign integration

## Updating the user Context

The context is a Dictionary which define the current user of your app. This Dictionary is sent and used by the Flagship decision API as targeting for campaign allocation. For example, you could pass a VIP status in the context and then the decision APIapi would enable or disable a specific feature flag.


<br>
The sdk provides some methods for pushing new context values:
<br>

Theses functions update the visitor context value matching the given key. A new context value associated with this key will be created if there is no previous matching value.

```swift

/// Here we set the context before start the FlagShip
// Add basketNumber with value 10 in the user context
ABFlagShip.sharedInstance.context("basketNumber", 10)

// Add isVipUser with true value in the user context
ABFlagShip.sharedInstance.context("isVipUser", true) 

// Add name  with value "alice" in the user context       
ABFlagShip.sharedInstance.context("name", "alice")

// Add valueKey with value 1.2 in the user context
ABFlagShip.sharedInstance.context("valueKey", 1.2)

// Start FlagShip 
ABFlagShip.sharedInstance.startFlagShip("idVisitor") { (state) in

DispatchQueue.main.async {

// Get title for banner
let title = ABFlagShip.sharedInstance.getModification("bannerTitle", defaultString: "More Infos",activate: true)
// Set the title
self.bannerBtn.setTitle(title, for: .normal)
}
}


```
Adding a Boolean Value to the Context user <br>
`func context(_ key:String,  _ boolean:Bool)`<br>
Adding a  Double Value to the context user<br>
`func context(_ key:String,  _ double:Double)`<br>
Adding a  String Value to the context user<br>
`func context(_ key:String,  _ text:String)`<br>
Adding a Float Value to the context user<br>
`func context(_ key:String,  _ float:Float)`<br>


Parameter | Type | Description
--------- | ------- | -----------
key | String | key to associate with the following value
value | String, Double, Boolean | FLoat


## Synchronizing campaigns

Synchronizing campaign modifications allows you to automatically call the Flagship decision API, which makes the allocation according to the user context and gets all their modifications. All the applicable modifications are stored in the SDK and are updated asynchronously when syncCampaignModifications() is called.

<br>

`public func updateContext(_ contextvalues:Dictionary<String,Any>, sync:((FlagshipState)->Void)?)`

```Swift

Here, for example, update VIP user info and adapt the UI...

// update isVipUser with false value in the user context
ABFlagShip.sharedInstance.updateContext(["isVipUser":false]) { (state) in

// In this block you will have new values updated for non VIP users

DispatchQueue.main.async {

// Get title for banner
let title = ABFlagShip.sharedInstance.getModification("bannerTitle", defaultString: "More Infos",activate: true)
// Set the title
self.bannerBtn.setTitle(title, for: .normal)
}
}
```

Parameter | Type | Description
--------- | ------- | -----------
contextvalues | Dictionary | represent keys/Value for the context 
sync | Block to execute once the sync is completed

This block will be executed once the new values given by the decision API are ready.



## Retrieving modifications and Activation

Once the campaign has been allocated and synchronized, all the modifications are stored on the SDK. You can retrieve them with the following functions:

```swift


```

<br>

Get the value for key (given by the decision API), this shows the default value that will be used when the key doesn’t match any modification values.

Get Modification for boolean key<br>
`func getModification(_ key:String, defaultBool:Bool, activate:Bool) -> Bool`<br>

Get Modification for String key<br>
`func getModification(_ key:String, defaultString:String, activate:Bool) -> String`<br>

Get Modification for Double key<br>
`func getModification(_ key:String, defaultDouble:Double, activate:Bool) -> Double`<br>

Get Modification for Float key<br>
`func getModification(_ key:String, defaulfloat:Float, activate:Bool) -> Float`<br>

Get Modification for Int key<br>
`func getModification(_ key:String, defaultInt:Int, activate:Bool) -> Int`<br>
<br>

Parameter | Type | Description
--------- | ------- | -----------
key | String, Boolean, Int, Float, Double | key associated with the modification.
default | String, Boolean, Int, Float, Double | default value returned when the key doesn't match any modification value.
activate | Boolean | **optional** (false by default) Set this parameter to true to automatically report on our server: the current visitor has seen this modification. You may also do it afterwards by calling activateModification().



Once a modification has been printed on the screen for a user, you must send an activation event to tell Flagship that the user has seen this specific variation.

```swift
ABFlagShip.sharedInstance.getModification("bannerTitle", defaultString: "More Infos", activate: true)

```


# Hit Tracking

This section helps you send tracking and learn how to build hits in order to approve campaign goals

The types of Hits are as follows: Page, Transaction, Item, Event. They must all be sent with the following function:

<br>

`func sendTracking<T: FSTrackingProtocol>(_ event:T)`

<br>

## Page

```swift
let eventPage = FSPageTrack("loginScreen")
ABFlagShip.sharedInstance.sendTracking(eventPage)
```

```objc

```
This hit should be sent each time a visitor arrives on a new interface. 
<b>FSPageTrack</b> class represents this hit and requires interfaceName string parameter


`init(_ interfaceName:String)`

Parameter | Type | Description
--------- | ------- | -----------
String | **required** interface name


## Transaction

Hit to send when a user completes a Transaction
<b>FSTransactionTrack</b> represents this hit and requires TransactionId and affiliation


```swift
let transacEvent:FSTransactionTrack = FSTransactionTrack("transacId","mobile_purchases")
ABFlagShip.sharedInstance.sendTracking(transacEvent)

```


`init(_ transactionId:String!, _ affiliation:String!)` <br>

Parameter | Type | Description
--------- | ------- | -----------
transactionId | String | **required** Transaction unique identifier.
affiliation | String | **required** Transaction name. Name of the goal in the reporting.
revenue | Float | **optional** Total revenue associated with the transaction. This value should include any shipping or tax costs.
shipping | Float | **optional** Specifies the total shipping cost of the transaction.
tax | Float | **optional** Specifies the total taxes of the transaction.
currency | String | **optional** Specifies the currency used for all transaction currency values. Value should be a valid ISO 4217 currency code.
paymentMethod | String | **optional** Specifies the payment method for the transaction.
itemCount | Int | **optional** Specifies the number of items for the transaction.
couponCode | String | **optional** Specifies the coupon code used by the customer for the transaction.

## Item

```swift
let itemEvent:FSItemTrack = FSItemTrack("transacId", "productName")
ABFlagShip.sharedInstance.sendTracking(itemEvent)

```
Hit to send an item associated with a transaction. Items must be sent after the corresponding transaction.

<b>FSItemTrack</b> represents this hit and requires transaction id and product name

`init(_ transactionId:String!, _ name:String!)`
<br>

Parameter | Type | Description
--------- | ------- | -----------
transactionId | String | **required** Transaction unique identifier.
product name | String | **required** Product name.
price | Float | **optional** Specifies the item price.
itemCode | String | **optional** Specifies the item code or SKU.
itemCategory | String | **optional** Specifies the item category.
itemQuantity | Int | **optional** Specifies the item quantity

## Event

```Swift
let event:FSEventTrack =  FSEventTrack(.Action_Tracking, "click")
ABFlagShip.sharedInstance.sendTracking(event)

```

Hit which represents an event. It can be anything you want: for example a click or a newsletter subscription.

<b>FSEventTrack</b>  represents this hit and requires a category event and action name string

<b>FSCategoryEvent</b>  can be  Action_Tracking  or  User_Engagement   

`init(_ eventCategory:FSCategoryEvent, _ eventAction:String)`

<br>

Parameter | Type | Description
--------- | ------- | -----------
category | EventCategory | **required** category of the event (ACTION_TRACKING or USER_ENGAGEMENT).
action | String | **required** the event action.
label | String | **optional** label of the event.
valude | Number | **optional** Specifies a value for this event. must be non-negative.

## Common parameter for Hits

```Swift
// create event
let eventPage = FSPageTrack("loginScreen")
// fill data for event page   
eventPage.userIp = "168.192.1.0"
eventPage.sessionNumber = 12
eventPage.screenResolution = "750 x 1334"
eventPage.screenColorDepth = "#fd0027"
eventPage.sessionNumber = 1
eventPage.userLanguage = "fr"
eventPage.sessionEventNumber = 2
// Send Event
ABFlagShip.sharedInstance.sendTracking(eventPage)

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
Logs are enabled by default. If you want to stop logs, set the “enableLogs” to false


```Swift
// Stop Logs displaying
ABFlagShip.sharedInstance.enableLogs = false
```
