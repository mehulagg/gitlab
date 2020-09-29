# frozen_string_literal: true
#
# Ruby 2.7 introduced noisy warnings to flag planned incompatibility of
# keyword arguments in Ruby 3.0:
# https://www.ruby-lang.org/en/news/2019/12/12/separation-of-positional-and-keyword-arguments-in-ruby-3-0/
#
# In development and in production, we silence these warnings since we
# already have an issue for them
# (https://gitlab.com/gitlab-org/gitlab/-/issues/257438). We log them to
# the deprecations/ folder in CI.
kwargs_warnings = [
  %r{warning: Using the last argument as keyword parameters is deprecated},
  %r{warning: Passing the keyword argument as the last hash parameter is deprecated},
  %r{warning: Splitting the last argument into positional and keyword parameters is deprecated}
]

if Rails.env.production? || Rails.env.development?
  DeprecationToolkit::Configuration.allowed_deprecations = kwargs_warnings
elsif ENV.key?('CI')
  DeprecationToolkit::Configuration.deprecation_path = 'deprecations'
  DeprecationToolkit::Configuration.behavior = DeprecationToolkit::Behaviors::Record
  DeprecationToolkit::Configuration.warnings_treated_as_deprecation = kwargs_warnings
end
