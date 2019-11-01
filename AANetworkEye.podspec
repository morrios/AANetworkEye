#
#  Be sure to run `pod spec lint AANetworkEye.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "AANetworkEye"
  s.version      = "0.4"
  s.summary      = "iOS 网络监控"

  s.description  = <<-DESC
一个监控APP内网络请求的库,缓存到本地
                   DESC

  s.homepage     = 'https://github.com/morrios/AANetworkEye'
  s.license      =  'MIT'

  s.author             = { 'morrios' => '13720036734@163.com' }
  s.ios.deployment_target = '8.0'

  s.source       ={ :git => 'https://github.com/morrios/AANetworkEye.git', :tag => s.version.to_s }

  s.source_files  ='Classes/**/*'
  s.frameworks = 'UIKit', 'Foundation'
  s.dependency 'FMDB'

end
