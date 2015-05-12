Pod::Spec.new do |s|

  s.name         = "SHPRACAdditions"
  s.version      = "0.1.2"
  s.summary      = "Handy additions to the Reactive Cocoa framework"

  s.homepage     = "https://github.com/shapehq/SHPRACAdditions"
  s.license      = "MIT"
  s.author             = { "Mikkel Selsøe Sørensen" => "mikkel@shape.dk" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "git@github.com:shapehq/SHPRACAdditions.git", tag: s.version }
  s.source_files  = "Classes", "Classes/**/*.{h,m}"
  # s.public_header_files = "Classes/**/*.h"
  s.requires_arc = true
  s.dependency "ReactiveCocoa", "~> 2.4.4"
  s.prefix_header_contents = '#import "ReactiveCocoa.h"'

end
