Gem::Specification.new do |s|
  s.name = 'apphtml_layer'
  s.version = '0.1.0'
  s.summary = 'Add a basic HTML wrapper to your Ruby object. ' + 
      'Suitable for use with a web server.'
  s.authors = ['James Robertson']
  s.files = Dir['lib/apphtml_layer.rb']
  s.add_runtime_dependency('c32', '~> 0.3', '>=0.3.0')    
  s.add_runtime_dependency('kramdown', '~> 2.3', '>=2.3.0')  
  s.signing_key = '../privatekeys/apphtml_layer.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@jamesrobertson.eu'
  s.homepage = 'https://github.com/jrobertson/apphtml_layer'
end
