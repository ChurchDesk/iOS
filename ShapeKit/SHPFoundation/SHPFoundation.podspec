Pod::Spec.new do |s|
  s.name                  = 'SHPFoundation'
  s.version               = '2.4.0'
  s.summary               = 'The SHPFoundation provides basic support for all SHAPE projects'
  s.author                = { 'Ole Gammelgaard Poulsen' => 'ole@shape.dk', 'Philip Bruce' => 'philip@shape.dk' }
  s.source                = { :git => 'git@github.com:shapehq/SHPFoundation.git', :tag => s.version.to_s }
  s.source_files          = 'Source/**/*.{h,m}'
  s.requires_arc 		      = true
  s.ios.deployment_target = '6.0'
  s.osx.deployment_target = '10.9'
end
