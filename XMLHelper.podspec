Pod::Spec.new do |s|
s.name             = 'XMLHelper'
s.version          = '0.1.2'
s.summary          = 'Simple XML parser'

s.description      = <<-DESC
This XMLHelper will parse the xml data for you, and provides some convenient usage
DESC

s.homepage         = 'https://github.com/GeekXiaowei/XMLHelper'
s.license          = { :type => 'MIT', :file => 'LICENSE' }
s.author           = { 'Xu Weiting' => 'geek_xwt@163.com' }
s.source           = { :git => 'https://github.com/GeekXiaowei/XMLHelper.git', :tag => s.version.to_s }

s.ios.deployment_target = '11.0'
s.swift_version    = '4.0'
s.source_files = 'XMLModeler/XML*.swift'

end
