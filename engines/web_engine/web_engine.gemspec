# frozen_string_literal: true

$:.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'web_engine/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = 'web_engine'
  spec.version     = WebEngine::VERSION
  spec.authors     = ['nmilojevic1']
  spec.email       = ['nmilojevic@gitlab.com']
  spec.summary     = 'Summary of WebEngine.'
  spec.description = 'Description of WebEngine.'
  spec.license     = 'MIT'
  spec.homepage    = 'https://rubygems.org/gems/example'
  spec.required_ruby_version = '>= 2.7.2'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'http://gitlab.com'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  spec.add_dependency 'apollo_upload_server', '~> 2.0.2'
  spec.add_dependency 'graphql', '~> 1.11.4'
  # NOTE: graphiql-rails v1.5+ doesn't work: https://gitlab.com/gitlab-org/gitlab/issues/31771
  # TODO: remove app/views/graphiql/rails/editors/show.html.erb when https://github.com/rmosolgo/graphiql-rails/pull/71 is released:
  # https://gitlab.com/gitlab-org/gitlab/issues/31747
  spec.add_dependency 'graphiql-rails', '~> 1.4.10'

  spec.add_dependency 'graphql-docs', '~> 1.6.0'
  spec.add_dependency 'rails', '~> 6.0.3', '>= 6.0.3.3'

  # API
  # Locked at Grape v1.4.0 until https://github.com/ruby-grape/grape/pull/2088 is merged
  # Remove config/initializers/grape_patch.rb
  spec.add_dependency 'grape', '= 1.4.0'
end
