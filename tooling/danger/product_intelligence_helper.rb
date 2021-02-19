# frozen_string_literal: true

module Tooling
  module Danger
    module ProductIntelligenceHelper
      ANY_CHANGE = Object.new
      FILE_CHANGES = {
        tracking: {
          'lib/gitlab/tracking.rb' => ANY_CHANGE,
          'spec/lib/gitlab/tracking_spec.rb' => ANY_CHANGE,
          'app/helpers/tracking_helper.rb' => ANY_CHANGE,
          'spec/helpers/tracking_helper_spec.rb' => ANY_CHANGE,
          'app/assets/javascripts/tracking.js' => ANY_CHANGE,
          'spec/frontend/tracking_spec.js' => ANY_CHANGE,
          'generator_templates/usage_metric_definition/metric_definition.yml' => ANY_CHANGE,
          'lib/generators/rails/usage_metric_definition_generator.rb' => ANY_CHANGE,
          'spec/lib/generators/usage_metric_definition_generator_spec.rb' => ANY_CHANGE,
          'config/metrics/schema.json' => ANY_CHANGE
        },
        usage_data: {
          /usage_data/ => ANY_CHANGE
        },
        metrics: {
          %r{config/metrics/.*\.yml} => ANY_CHANGE
        },
        metrics_dictionary: {
          'doc/development/usage_ping/dictionary.md' => ANY_CHANGE
        },
        snowplow: {
          /\.rb$/ => /Gitlab::Tracking\.event/,
          /\.(js|vue)$/ => Regexp.union(
            'Tracking.event',
            /\btrack\./,
            'data-track-event'
          ),
          /\.haml$/ => %r{\b(event|track)\b}
        }
      }.freeze

      # returns a Hash: <section> => [<file>, ...]
      # Example: { tracking: ['lib/gitlab/tracking.rb', ...], metrics: [ ... ] }
      def self.determine_changed_files(changed_files)
        {
          tracking: FILE_CHANGES[:tracking].each do |file_pattern, content_pattern|
            changed_files.grep(file_pattern)
          end,
          usage_data: [],
          metrics: [],
          snowplow: []
        }
      end
    end
  end
end
