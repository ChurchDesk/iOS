source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '8.0'
inhibit_all_warnings!

pod 'DCIntrospect-ARC', :head, :configurations => ['Debug']
pod 'Masonry', '~> 0.6.1'
pod 'ReactiveCocoa', '~> 2.4.7'
pod 'Haneke', '~> 1.0.1'
pod 'SHPKeyboardAwareness', '~> 2.0.0'
pod 'SSKeychain', '~> 1.2.2'
pod 'FormatterKit', '~> 1.8.0'
pod 'AutoCoding', '~> 2.2.1'
pod 'MBProgressHUD', '~> 0.9.1'
pod 'GoogleAnalytics-iOS-SDK', '~> 3.10'

#ShapeKit
pod 'SHPUIKit', :path => '../ShapeKit/SHPUIKit/'
pod 'SHPFoundation', :path => '../ShapeKit/SHPFoundation/'
pod 'SHPCalendarPicker', :path => '../ShapeKit/SHPCalendarPicker/'
pod 'SHPSideMenu', :path => '../ShapeKit/SHPSideMenu/'
pod 'SHPNetworking', :path => '../ShapeKit/SHPNetworking/'
pod 'SHPRACAdditions', :path => '../ShapeKit/SHPRACAdditions/'
pod 'SHPUIInjection', :path => '../ShapeKit/SHPUIInjection/', :configurations => ['Debug']

# Will inject pod license acknowledgements into Settings bundle
post_install do | installer |
    require 'fileutils'
    FileUtils.cp_r('Pods/Target Support Files/Pods/Pods-Acknowledgements.plist', 'Resources/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
    
    installer.project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] = '$(inherited) USE_REACTIVE_EXTENSION=1'
        end
    end
end

