#
#  Be sure to run `pod spec lint AANetworkEye.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  s.name         = "AANetworkEye"
  s.version      = "0.1"
  s.summary      = "iOS 网络监控"

  s.description  = <<-DESC
一个监控APP内网络请求的库
                   DESC

  s.homepage     = 'https://github.com/morrios/AANetworkEye'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }

  s.author             = { 'morrios' => '13720036734@163.com' }

  s.source       ={ :git => 'https://github.com/morrios/AANetworkEye.git', :tag => s.version.to_s }

  s.source_files  ='Classes/**/*'
  s.frameworks = 'UIKit', 'Foundation'
  s.dependency 'FMDB'

end
