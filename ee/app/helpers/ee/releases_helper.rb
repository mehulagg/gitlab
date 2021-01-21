# frozen_string_literal: true

module EE
  module ReleasesHelper
    extend ActiveSupport::Concern
    extend ::Gitlab::Utils::Override

    override :group_milestone_project_releases_available?
    def group_milestone_project_releases_available?(project)
      project.feature_available?(:group_milestone_project_releases).to_s
    end
  end
end
