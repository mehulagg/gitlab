# frozen_string_literal: true

module Gitlab
  module Template
    class CustomMetricsDashboardYmlTemplate < CustomTemplate
      class << self
        def extension
          '.yml'
        end

        def base_dir
          'metrics-dashboards/'
        end
      end
    end
  end
end
