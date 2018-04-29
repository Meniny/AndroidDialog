Pod::Spec.new do |s|
    s.name                  = "AndroidDialog"
    s.version               = "1.0.0"
    s.summary               = "Pythonic RegEx library."
    s.homepage              = "https://github.com/Meniny/AndroidDialog"
    s.social_media_url      = 'https://meniny.cn/'
    s.author                = { "Elias Abel" => "admin@meniny.cn" }
    s.license               = { :type => "MIT", :file => "LICENSE.md" }
    s.source                = { :git => "https://github.com/Meniny/AndroidDialog.git", :tag => s.version.to_s }
    s.requires_arc          = true
    s.source_files          = 'AndroidDialog/**/*.{swift,h}'
    s.swift_version         = '4.1'
    s.pod_target_xcconfig   = { 'SWIFT_VERSION' => '4.0' }
    s.ios.deployment_target = "9.0"
    s.dependency               "JustLayout"
end
