# frozen_string_literal: true
class ProtectedEnvironment < ApplicationRecord
  include ::Gitlab::Utils::StrongMemoize

  belongs_to :project, foreign_key: :project_id
  belongs_to :group, foreign_key: :group_id
  has_many :deploy_access_levels, inverse_of: :protected_environment

  accepts_nested_attributes_for :deploy_access_levels, allow_destroy: true

  validates :deploy_access_levels, length: { minimum: 1 }
  validate :name_or_tier
  validate :project_or_group

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

  def accessible_to?(user)
    deploy_access_levels
      .any? { |deploy_access_level| deploy_access_level.check_access(user) }
  end

  def name_or_tier
    unless name.present? || tier.present?
      errors.add(:base, 'Either name or tier must be specified')
    end
  end

  def project_or_group
    unless project_level? || group_level?
      errors.add(:base, 'Either project-level or group-level must be specified')
    end
  end

  def project_level?
    project_id.present?
  end

  def group_level?
    group_id.present?
  end
end
