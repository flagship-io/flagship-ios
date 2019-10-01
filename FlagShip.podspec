#
# Be sure to run `pod lib lint FlagShip.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'FlagShip'
  s.version          = '0.0.1'
  s.summary          = 'Flagship SDK '

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
The Flagship SDK is an iOS framework whose purpose is to help you run Flagship campaigns on your native ios app
                       DESC

  s.homepage         = 'https://app.flagship.io/login'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Adel' => 'adel@abtasty.com' }
  s.source           = { :git => 'https://gitlab.com/abtasty-public/mobile/flagship-ios.git', :tag => s.version.to_s }
  s.swift_version    = '4.2'
  s.frameworks = 'SystemConfiguration'

  #s.dependency       "ReachabilitySwift"

 
  s.ios.deployment_target = '8.0'

  s.source_files = 'FlagShip/Classes/**/*'
  
  # s.resource_bundles = {
  #   'FlagShip' => ['FlagShip/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
