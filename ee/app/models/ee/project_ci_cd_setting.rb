# frozen_string_literal: true

module EE
  module ProjectCiCdSetting
    extend ActiveSupport::Concern

    def merge_pipelines_enabled?
      project.feature_available?(:merge_pipelines) && super
    end

    ##
    # The `disable_merge_trains` feature flag is meant to be used for dogfooding
    # pipelines for merged results in gitlab-org/gitlab project.
    # This feature flag is never meant to be enabled for the entire instance.
    # See more context in https://gitlab.com/gitlab-org/gitlab/issues/200037
    def merge_trains_enabled?
      return false if ::Feature.enabled?(:disable_merge_trains, project)

      merge_pipelines_enabled? && project.feature_available?(:merge_trains)
    end

    def merge_pipelines_were_disabled?
      saved_change_to_attribute?(:merge_pipelines_enabled, from: true, to: false)
    end

    def auto_rollback_enabled?
      super && ::Gitlab::Ci::Features.auto_rollback_available?(project)
    end
  end
end
