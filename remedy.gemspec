lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'remedy/version'

Gem::Specification.new do |gem|
  gem.name          = 'remedy'
  gem.version       = Remedy::VERSION
  gem.authors       = ['Anthony M. Cook']
  gem.email         = ['github@anthonymcook.com']
  gem.description   = 'Pure Ruby console interaction library in the vein of Curses with MVC-style seperation of concerns.'
  gem.summary       = 'Pure Ruby Console Interaction Library'
  gem.licenses      = ['MIT']
  gem.homepage      = 'http://github.com/acook/remedy'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'rubocop'
  gem.add_development_dependency 'rubocop-performance'
  gem.add_development_dependency 'rubocop-rspec'
end
