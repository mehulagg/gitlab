# frozen_string_literal: true

return if Rails.env.production?

namespace :spec do
  desc 'Run the code examples in engines/web_engine/spec/'
  RSpec::Core::RakeTask.new(:web_engine) do |t|
    t.pattern = 'engines/web_engine/spec/**/*_spec.rb'
  end
end
