#
#  Be sure to run `pod spec lint CSPagedScrollView.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|
  spec.name         = "CSPagedScrollView"
  spec.version      = "0.0.3"
  spec.summary      = "Paged scroll view wrote in swiftUI."

  spec.description  = <<-DESC
  Pure SwiftUI framework, support pull to refresh and load more in custom scroll view.
  			DESC

  spec.homepage     = "https://github.com/cristysui/CSPagedScrollView"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author             = { "cristy" => "cristy.xinsui@gmail.com" }
  spec.source       = { :git => "https://github.com/cristysui/CSPagedScrollView.git", :tag => "#{spec.version}" }

  spec.swift_version = "5.0"
  spec.ios.deployment_target = '14.0'

  spec.source_files = 'Sources/CSPagedScrollView/*.swift'

end
