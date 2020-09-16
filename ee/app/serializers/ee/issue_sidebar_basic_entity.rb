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

      expose :request_cve_enabled do |issuable|
        request_cve_enabled?(issuable.project) \
          && issuable.to_ability_name == 'issue' \
          && issuable.respond_to?(:confidential) && issuable.confidential \
          && can?(current_user, :admin_project, issuable.project)
      end
    end
  end
end
