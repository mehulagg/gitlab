# frozen_string_literal: true
class GroupProtectedEnvironment < ApplicationRecord
  include ::Gitlab::Utils::StrongMemoize

  belongs_to :group
  has_many :deploy_access_levels, inverse_of: :protected_environment

  accepts_nested_attributes_for :deploy_access_levels, allow_destroy: true

  validates :deploy_access_levels, length: { minimum: 1 }
  validates :tier, :group, presence: true

  scope :sorted_by_tier, -> { order(:tier) }

  class << self
    def for_environment(environment)
      raise ArgumentError unless environment.is_a?(::Environment)

      key = "group_protected_environment:for_environment:#{environment.project_id}:#{environment.name}"

      ::Gitlab::SafeRequestStore.fetch(key) do
        where(group: environment.project.group.self_and_ancestors_ids, tier: environment.tier)
      end
    end
  end

  def accessible_to?(user)
    deploy_access_levels
      .any? { |deploy_access_level| deploy_access_level.check_access(user) }
  end
end
