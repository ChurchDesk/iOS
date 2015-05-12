Pod::Spec.new do |s|
  s.name                = "SHPUIInjection"
  s.version             = "0.0.3"
  s.summary             = ""
  s.author              = { "Peter Gammelgaard" => "peter@shape.dk" }
  s.source              = { :git => "git@github.com:shapehq/SHPUIInjection.git", :tag => s.version.to_s }
  s.source_files        = 'Source/**/*.{h,m}'
  s.platform            = :ios, '7.0'
  s.requires_arc        = true
  s.dependency 'dyci'
end
