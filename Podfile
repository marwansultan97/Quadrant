# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

target 'Quadrant' do
  # Comment the next line if you don't want to use dynamic frameworks
  
  
  use_frameworks! :linkage => :static

pod 'Firebase/Auth'
pod 'Firebase/Firestore'
pod 'Firebase/Database'
pod 'GeoFire'
pod 'SideMenuSwift'
pod 'ReachabilitySwift'
pod 'TTGSnackbar'
pod 'NVActivityIndicatorView'
pod 'SVProgressHUD', :git => 'https://github.com/SVProgressHUD/SVProgressHUD.git'
pod 'RxSwift'
pod 'RxCocoa'
pod 'JSSAlertView'
pod 'Firebase/Messaging'

end


post_install do |installer|
 installer.pods_project.targets.each do |target|
  target.build_configurations.each do |config|
   config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
  end
 end
end
