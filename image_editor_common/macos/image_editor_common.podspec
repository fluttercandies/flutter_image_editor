#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_image_editor.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'image_editor_common'
  s.version          = '1.0.0'
  s.summary          = 'A flutter plugin for edit image data.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'https://github.com/fluttercandies/flutter_image_editor'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }

  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'

  s.osx.dependency 'FlutterMacOS'
  s.ios.dependency 'Flutter'

  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.15'
  
  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
end
