# Uncomment this line to define a global platform for your project
platform :ios, '10.0'

target 'ShoppingList' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  pod 'Material', '~> 2.0'
  pod 'ChameleonFramework/Swift', :git => 'https://github.com/ViccAlexander/Chameleon.git'
  pod 'FontAwesome.swift'
  pod 'Spring', :git => 'https://github.com/MengTo/Spring.git', :branch => 'swift3'
  pod 'NVActivityIndicatorView'
  pod 'SwiftyUserDefaults'
  pod 'Graph', '~> 2.0'
  pod 'SCLAlertView'
  pod 'CircleMenu', '~> 2.0.1'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end
