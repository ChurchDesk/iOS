Pod::Spec.new do |s|
  s.name                = "SHPCalendarPicker"
  s.version             = "0.5.0"
  s.summary             = ""
  s.author              = { "Peter Gammelgaard" => "peter@shape.dk" }
  s.source              = { :git => "git@github.com:shapehq/SHPCalendarPicker.git", :tag => s.version.to_s }
  s.source_files        = 'Source'
  s.platform            = :ios, '7.0'
  s.resources			= 'SHPCalendarPickerResources.bundle'
  s.requires_arc        = true
  
  s.prefix_header_contents = <<-EOS
#ifdef __OBJC__
#import "SHPCalendarPicker.h"
#endif
  EOS
end
