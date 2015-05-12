Pod::Spec.new do |s|
  s.name         = "SHPUIKit"
  s.version      = "2.1.0"
  s.summary      = "SHPUIKit contains the most simple and most used UI elements for Shape projects."
  s.homepage     = "https://github.com/shapehq/SHPUIKit"
  s.author       = { "Kasper Kronborg" => "kasper@shape.dk", "Philip Bruce" => "philip@shape.dk" }
  s.source       = { :git => "git@github.com:shapehq/SHPUIKit.git", :tag => s.version.to_s }
  s.requires_arc = true
  s.platform     = :ios, '5.0'
  s.source_files = 'Source/**/*.{h,m}'
end
