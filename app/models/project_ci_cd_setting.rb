# frozen_string_literal: true

class ProjectCiCdSetting < ApplicationRecord
  belongs_to :project, inverse_of: :ci_cd_settings

  DEFAULT_GIT_DEPTH = 50

  before_create :set_default_git_depth

  validates :default_git_depth,
    numericality: {
      only_integer: true,
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: 1000
    },
    allow_nil: true

  default_value_for :forward_deployment_enabled, true

  def forward_deployment_enabled?
    super && ::Feature.enabled?(:forward_deployment_enabled, project, default_enabled: true)
  end

  def keep_latest_artifacts_available?
    # The project level feature can only be enabled when the feature is enabled instance wide
    Gitlab::CurrentSettings.current_application_settings.keep_latest_artifact? && keep_latest_artifact?
  end

  # Temporarily overriding this setting so that we can drop and readd the
  # columnn in order to reset the values to `false`.
  # https://gitlab.com/gitlab-org/gitlab/-/issues/333002
  def job_token_scope_enabled
    false
  end

  def job_token_scope_enabled?
    job_token_scope_enabled
  end

  def job_token_scope_enabled=(_value)
    nil
  end

  private

  def set_default_git_depth
    self.default_git_depth ||= DEFAULT_GIT_DEPTH
  end
end

ProjectCiCdSetting.prepend_mod_with('ProjectCiCdSetting')
