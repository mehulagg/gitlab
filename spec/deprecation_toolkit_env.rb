# frozen_string_literal: true

require 'deprecation_toolkit'
require 'deprecation_toolkit/rspec'

module DeprecationToolkitEnv
  # Taken from https://github.com/jeremyevans/ruby-warning/blob/1.1.0/lib/warning.rb#L18
  def self.kwargs_warning
    %r{warning: (?:Using the last argument (?:for `.+' )?as keyword parameters is deprecated; maybe \*\* should be added to the call|Passing the keyword argument (?:for `.+' )?as the last hash parameter is deprecated|Splitting the last argument (?:for `.+' )?into positional and keyword parameters is deprecated|The called method (?:`.+' )?is defined here)\n\z}
  end

  def self.configure!
    return unless ENV.key?('RECORD_DEPRECATIONS')

    # Enable ruby deprecations for keywords, it's suppressed by default in Ruby 2.7.2
    Warning[:deprecated] = true

    DeprecationToolkit::Configuration.test_runner = :rspec
    DeprecationToolkit::Configuration.deprecation_path = 'deprecations'
    DeprecationToolkit::Configuration.warnings_treated_as_deprecation = [kwargs_warning]
    DeprecationToolkit::Configuration.behavior = DeprecationToolkit::Behaviors::Record
  end
end
