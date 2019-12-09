# frozen_string_literal: true

module Gitlab
  module ApplicationSettingChecker
    class PumaRuggedChecker
      def self.check
        suboptimal_config = []
        puma_max_threads = ::Puma.cli_config.options[:max_threads]
        if puma_max_threads > 1 && Gitlab::ApplicationSettingChecker::RuggedDetector.rugged_enabled?
          suboptimal_config << {
            title: 'puma threads > 1 && rugged enabled',
            category: 'performance',
            description: 'When Rugged enabled, Puma threads > 1 will lead to performance issue.',
            suggestion: 'Change Puma.rb, set new workers to `current_workers * threads_per_worker`',
            extra_data:  {
              puma_config: "Puma.cli_config.options[:max_threads] = #{puma_max_threads}",
              rugged_enabled: true
            }
          }
        end

        suboptimal_config
      end
    end
  end
end
