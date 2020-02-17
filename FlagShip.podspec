#
# Be sure to run `pod lib lint FlagShip.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "FlagShip"
  s.version          = "1.1.0"
  s.summary          = "FlagShip SDK"

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
The FlagShip SDK is an iOS framework whose goal is to help you run FlagShip campaigns on your ios native app.
                       DESC

  s.homepage         = "https://app.flagship.io/login"
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'FlagShip' => 'adel@abtasty.com' }
  s.source           = { :git => 'https://github.com/abtasty/flagship-ios.git', :tag => s.version.to_s }
  s.frameworks       = 'SystemConfiguration'
 
  s.ios.deployment_target = "8.0"

  s.source_files = 'Source/**/*.swift'
  
  s.swift_version           = "5.0"
  end
