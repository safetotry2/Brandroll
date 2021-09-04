source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '13.2'
use_frameworks!
inhibit_all_warnings!

target 'Brandroll' do
  pod 'DKImagePickerController'
  pod 'Kingfisher'
  pod 'SVProgressHUD'
  pod 'SnapKit'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '5.3'
        end
    end
end
