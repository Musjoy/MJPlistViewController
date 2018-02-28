#
# Be sure to run `pod lib lint MJPlistViewController.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "MJPlistViewController"
  s.version          = "0.1.5"
  s.summary          = "This is view controller with table view which read the data from plist file."

  s.homepage         = "https://github.com/Musjoy/MJPlistViewController"
  s.license          = 'MIT'
  s.author           = { "Raymond" => "Ray.musjoy@gmail.com" }
  s.source           = { :git => "https://github.com/Musjoy/MJPlistViewController.git", :tag => "v-#{s.version}" }

  s.ios.deployment_target = '7.0'

  s.source_files = 'MJPlistViewController/Classes/**/*'

  s.user_target_xcconfig = {
    'GCC_PREPROCESSOR_DEFINITIONS' => 'MODULE_PLIST_CONTROLLER'
  }

  s.dependency 'ModuleCapability', '~> 0.1'
  s.prefix_header_contents = '#import "ModuleCapability.h"'

end
