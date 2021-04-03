# frozen_string_literal: true

module EE
  module Gitlab
    module Usage
      module MetricDefinition
        extend ActiveSupport::Concern

        class_methods do
          extend ::Gitlab::Utils::Override

          override :paths
          def paths
            @ee_paths ||= [Rails.root.join('ee', 'config', 'metrics', '[^agg]*', '*.yml')] + super
          end
        end
      end
    end
  end
end
