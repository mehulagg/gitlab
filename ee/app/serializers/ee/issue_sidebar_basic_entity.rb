# frozen_string_literal: true

module EE
  module IssueSidebarBasicEntity
    extend ActiveSupport::Concern

    prepended do
      expose :supports_epic?, as: :supports_epic

      expose :features_available do
        expose :supports_health_status?, as: :health_status

        expose :issue_weights do |issuable|
          issuable.weight_available?
        end

        expose :epics do |issuable|
          issuable.project&.group&.feature_available?(:epics)
        end
      end
    end
  end
end
