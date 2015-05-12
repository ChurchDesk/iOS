Pod::Spec.new do |s|
  s.name                = "SHPSideMenu"
  s.version             = "1.1.0"
  s.summary             = ""
  s.author              = { "Peter Gammelgaard" => "peter@shape.dk" }
  s.source              = { :git => "git@github.com:shapehq/SHPSideMenu.git", :tag => s.version.to_s }
  s.source_files        = 'Source'
  s.platform            = :ios, '7.0'
  s.requires_arc        = true
  s.dependency 'pop',   '~> 1.0.7'

  s.prefix_header_contents = <<-EOS
#ifdef __OBJC__
#import "SHPSideMenu.h"
#endif
  EOS
end
