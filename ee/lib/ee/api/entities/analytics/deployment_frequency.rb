# frozen_string_literal: true

module EE
  module API
    module Entities
      module Analytics
        class DeploymentFrequency < Grape::Entity
          format_with(:iso8601_date) { |datetime| datetime.to_date.iso8601 }

          expose :value
          expose :from, format_with: :iso8601_date
          expose :to, format_with: :iso8601_date
        end
      end
    end
  end
end
