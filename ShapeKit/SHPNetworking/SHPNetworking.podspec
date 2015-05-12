Pod::Spec.new do |s|
  s.name                = 'SHPNetworking'
  s.version             = '7.6.3'
  s.summary             = 'SHPNetworking provides easy API communication.'
  s.author              = { 'Ole Gammelgaard Poulsen' => 'ole@shape.dk' }
  s.source              = { :git => 'git@github.com:shapehq/SHPNetworking.git', :tag => s.version.to_s }
  s.source_files        = 'Source/**/*.{h,m}'
  s.requires_arc        = true
  s.platform            = :ios, '5.0'
end
