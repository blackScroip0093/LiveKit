#
# Be sure to run `pod lib lint liveSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'liveSDK'
  s.version          = '0.1.2'
  s.summary          = 'A short description of liveSDK.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/暮雪/liveSDK'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '暮雪' => 'zhaotongyue1@163.com' }
  s.source           = { :git => 'https://github.com/暮雪/liveSDK.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'liveSDK/Classes/**/*'
  s.static_framework = true
#  s.resources = "liveSDK/*.png"
  # s.resource_bundles = {
  #   'liveSDK' => ['liveSDK/Assets/*.png']
  # }
 

#   s.public_header_files = '/Classes/RxWebViewController/RxWebViewController.h'
#  s.prefix_header_contents = '#import "RxWebViewController.h"','#import "RxWebViewNavigationViewController.h"'
   s.libraries  = 'sqlite3.0','c','sqlite3','c++','iconv','z','resolv'
   s.frameworks = 'UIKit', 'MapKit','AudioToolbox','OpenAL','Metal','Foundation','MediaPlayer','SystemConfiguration','CoreTelephony','VideoToolbox','CoreMedia','CoreGraphics','AVFoundation','Accelerate','Security','AssetsLibrary','ReplayKit'
   # AudioEffectSettingKit
   s.dependency 'IQKeyboardManager'
   s.dependency 'Bugly'
   s.dependency 'RxSwift'
   s.dependency 'RxCocoa'
   s.dependency 'SnapKit'
   s.dependency 'Alamofire'
   s.dependency 'Toast-Swift'
   s.dependency 'Material'
   s.dependency 'SDWebImage', '~> 5.5.2'
   s.dependency 'Masonry'
   s.dependency 'MJExtension'
   s.dependency 'MJRefresh'
   s.dependency 'AFNetworking', '~> 3.1.0'
   s.dependency 'BlocksKit', '~> 2.2.5'
   s.dependency 'CWStatusBarNotification', '~> 2.3.5'
   s.dependency 'YYCache', '~> 1.0.4'
   s.dependency 'JXCategoryView', '~> 1.5.7'
   s.dependency 'MBProgressHUD', '~> 1.2.0'
#   s.dependency 'TEduBoard_iOS'
   s.dependency 'CWStatusBarNotification', '~> 2.3.5'
end
