
Pod::Spec.new do |s|
  s.name             = 'ImageCacheable'
  s.version          = '0.1.0'
  s.summary          = 'Swift protocol to save images locally or cache in memory'
  s.description      = <<-DESC
Swift protocol to allow any object to easily save & retrieve a UIImage from local storage or in memory cache.
                       DESC

  s.homepage         = 'https://github.com/ssh88/ImageCacheable'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Shabeer Hussain' => 'shabeershussain@gmail.com' }
  s.source           = { :git => 'https://github.com/ssh88/ImageCacheable.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/sshdeveloper'

  s.ios.deployment_target = '8.0'
  s.source_files = 'ImageCacheable/Classes/**/*'
end
