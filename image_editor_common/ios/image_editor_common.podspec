#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint image_editor.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'image_editor_common'
  s.version          = '1.0.0'
  s.summary          = 'Edit your image data and output to file/memory.'
  s.description      = <<-DESC
Edit your image data and output to file/memory.
                       DESC
  s.homepage         = 'https://fluttercandies.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Flutter Candies' => 'admin@fluttercandies.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '9.0'
  
  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
end
