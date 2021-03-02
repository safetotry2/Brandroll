source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '13.2'
use_frameworks!
inhibit_all_warnings!

target 'LogInProgrammatic' do
  pod 'DKImagePickerController'
  pod 'Firebase/Auth'
  pod 'Firebase/Firestore'
  pod 'Firebase/Storage'
  pod 'Firebase/Messaging'
  pod 'Firebase/Core'
  pod 'Firebase/Database'
  pod 'Kingfisher'
  pod 'SVProgressHUD'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '5.3'
        end
    end
end
