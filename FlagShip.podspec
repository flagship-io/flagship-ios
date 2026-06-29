#
# Be sure to run `pod lib lint FlagShip.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "FlagShip"
 
  s.version          = "4.0.3"
  s.summary          = "Flagship SDK"
  
# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
The FlagShip SDK is an iOS framework whose goal is to help you run Flagship campaigns on your native app.
                       DESC

  s.homepage         = "https://app.flagship.io/login"
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'FlagShip' => 'adel@abtasty.com' }
  s.source           = { :git => 'https://github.com/flagship-io/flagship-ios.git', :tag => s.version.to_s }
  
  s.ios.deployment_target  = "11.0"
  s.tvos.deployment_target = "11.0"
  s.osx.deployment_target = "10.13"
  #s.watchos.deployment_target = "5.0"   #publishing podspecs that support watchOS platform is currently broken under Xcode 14
  
  

  s.swift_version = "5.0"

  s.subspec 'API' do |ss|
    ss.source_files = 'FlagShip/Source/API/**/*.swift'
  end

  s.subspec 'Audience' do |ss|
    ss.source_files = 'FlagShip/Source/Audience/**/*.swift'
  end

  s.subspec 'Cache' do |ss|
    ss.source_files = 'FlagShip/Source/Cache/**/*.swift'
    ss.resources    = 'FlagShip/Source/Cache/**/*.xcdatamodeld'
  end

  s.subspec 'Configs' do |ss|
    ss.source_files = 'FlagShip/Source/Configs/**/*.swift'
  end

  s.subspec 'Core' do |ss|
    ss.source_files = 'FlagShip/Source/Core/**/*.swift'
  end

  s.subspec 'Decision' do |ss|
    ss.source_files = 'FlagShip/Source/Decision/**/*.swift'
  end

  s.subspec 'Logger' do |ss|
    ss.source_files = 'FlagShip/Source/Logger/**/*.swift'
  end

  s.subspec 'Models' do |ss|
    ss.source_files = 'FlagShip/Source/Models/**/*.swift'
  end

  s.subspec 'Storage' do |ss|
    ss.source_files = 'FlagShip/Source/Storage/**/*.swift'
  end

  s.subspec 'Strategy' do |ss|
    ss.source_files = 'FlagShip/Source/Strategy/**/*.swift'
  end

  s.subspec 'Tools' do |ss|
    ss.source_files = 'FlagShip/Source/Tools/**/*.swift'
  end

  s.subspec 'Tracking' do |ss|
    ss.source_files = 'FlagShip/Source/Tracking/**/*.swift'
  end

  s.subspec 'Troubleshooting' do |ss|
    ss.source_files = 'FlagShip/Source/Troubleshooting/**/*.swift'
  end

end
