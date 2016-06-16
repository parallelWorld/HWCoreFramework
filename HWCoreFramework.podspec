#
# Be sure to run `pod lib lint HWCoreFramework.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'HWCoreFramework'
  s.version          = '0.1.0'
  s.summary          = 'A short description of HWCoreFramework.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/<GITHUB_USERNAME>/HWCoreFramework'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ParallelWorld' => '654269765@qq.com' }
  s.source           = { :git => 'https://github.com/<GITHUB_USERNAME>/HWCoreFramework.git', :tag => s.version.to_s }

  s.ios.deployment_target = '7.0'

  s.source_files = 'HWCoreFramework/Classes/**/*'

  # s.resource_bundles = {
  #   'HWCoreFramework' => ['HWCoreFramework/Assets/*.png']
  # }

  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
s.dependency 'Aspects'
s.dependency 'Masonry'
s.dependency 'UITableView+FDTemplateLayoutCell'
s.dependency 'MJRefresh'
end
