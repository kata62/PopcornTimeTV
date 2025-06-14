use_frameworks!

source 'https://github.com/CocoaPods/Specs'
source 'https://github.com/PopcornTimeTV/Specs'

def pods
    pod 'PopcornTorrent', '~> 1.3.0'
    pod 'XCDYouTubeKit', '~> 2.8.0'
    pod 'Alamofire', '~> 4.9.0'
    pod 'AlamofireImage', '~> 3.5.0'
    pod 'SwiftyTimer', '~> 2.1.0'
    pod 'FloatRatingView', '~> 3.0.1'
    pod 'Reachability', :git => 'https://github.com/tonymillion/Reachability'
    pod 'MarqueeLabel', '~> 4.0.0'
    pod 'ObjectMapper', '~> 3.5.0'
end

target 'PopcornTimeiOS' do
    platform :ios, '15.6'
    pods
    pod 'AlamofireNetworkActivityIndicator', '~> 2.4.0'
    pod 'google-cast-sdk', '~> 4.4'
    pod 'OBSlider', '~> 1.1.1'
    pod '1PasswordExtension', '~> 1.8.4'
    pod 'MobileVLCKit', '~> 3.3.0'
end

target 'PopcornTimetvOS' do
    platform :tvos, '15.6'
    pods
    pod 'TvOSMoreButton', '~> 1.2.0'
    pod 'TVVLCKit', '~> 3.3.0'
    pod 'MBCircularProgressBar', '~> 0.3.5-1'
end

target 'TopShelf' do
    platform :tvos, '15.6'
    pod 'ObjectMapper', '~> 3.5.0'
end

def kitPods
    pod 'Alamofire', '~> 4.9.0'
    pod 'ObjectMapper', '~> 3.5.0'
    pod 'SwiftyJSON', '~> 5.0.0'
    pod 'Locksmith', '~> 4.0.0'
end

target 'PopcornKit tvOS' do
    platform :tvos, '15.6'
    kitPods
end

target 'PopcornKit iOS' do
    platform :ios, '15.6'
    kitPods
    pod 'google-cast-sdk', '~> 4.4'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            #config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.6'
            config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
            config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ""
            config.build_settings['CODE_SIGNING_REQUIRED'] = "NO"
            config.build_settings['CODE_SIGNING_ALLOWED'] = "NO"
        end
        if ['FloatRatingView-iOS', 'FloatRatingView-tvOS'].include? target.name
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '5.0'
            end
        end 
    end
end
