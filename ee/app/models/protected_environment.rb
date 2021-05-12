# frozen_string_literal: true
class ProtectedEnvironment < ApplicationRecord
  include ::Gitlab::Utils::StrongMemoize

  belongs_to :project
  belongs_to :group
  has_many :deploy_access_levels, inverse_of: :protected_environment

  accepts_nested_attributes_for :deploy_access_levels, allow_destroy: true

  validates :deploy_access_levels, length: { minimum: 1 }
  validates :name, :project, presence: true
  validate :name_project_or_tier_group

  scope :sorted_by_name, -> { order(:name) }

  scope :with_environment_id, -> do
    select('protected_environments.*, environments.id AS environment_id')
      .joins('LEFT OUTER JOIN environments ON' \
             ' protected_environments.name = environments.name ' \
             ' AND protected_environments.project_id = environments.project_id')
  end

  scope :deploy_access_levels_by_group, -> (group) do
    ProtectedEnvironment::DeployAccessLevel
      .joins(:protected_environment).where(group: group)
  end

  class << self
    def for_environment(environment)
      raise ArgumentError unless environment.is_a?(::Environment)

      key = "protected_environment:for_environment:#{environment.project_id}:#{environment.name}"

      ::Gitlab::SafeRequestStore.fetch(key) do
        if Feature.enabled?(:group_level_protected_environments, environment.project.group, default_enabled: :yaml)
          where(project: environment.project_id, name: environment.name)
      end
    end
  end

  def accessible_to?(user)
    deploy_access_levels
      .any? { |deploy_access_level| deploy_access_level.check_access(user) }
  end

  private

  def name_project_or_tier_group
    unless (name.present? && project_id.present?) || (tier.present? && group_id.present?)
      erros.add('You must specify project_id with name or group_id with tier')
    end
  end
end
