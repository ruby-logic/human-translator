$LOAD_PATH.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'human_translator/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name          = 'human_translator'
  s.version       = HumanTranslator::VERSION
  s.authors       = ['Alek Niemczyk']
  s.email         = ['alek@rubylogic.pl']
  s.homepage      = 'http://rubylogic.eu'
  s.summary       = 'TO DO: Summary of HumanTranslator.'
  s.description   = 'TO DO: Description of HumanTranslator.'
  s.license       = 'MIT'

  s.files         = Dir[
                     'lib/**/*',
                     'lib/tasks/*',
                     'lib/tasks/rake_classes/*',
                     'LICENSE',
                     'Rakefile',
                     'README.md'
                    ]
  s.require_paths = %w[lib]

  s.add_development_dependency 'rubocop', '0.66'

  s.add_runtime_dependency 'bundler', '~> 1.3'
  s.add_runtime_dependency 'rails'
  s.add_runtime_dependency 'rake'
end
