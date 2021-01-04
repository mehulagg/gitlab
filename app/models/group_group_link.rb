# frozen_string_literal: true

class GroupGroupLink < ApplicationRecord
  include Expirable

  # 'shared_group' is the group being granted share access to shared_with_group
  #   - called 'shared_group' in API :id/share, and in GroupLinks::CreateService
  belongs_to :shared_group, class_name: 'Group', foreign_key: :shared_group_id

  # 'shared_with_group' is the group granting the share permission to shared_group
  #   - called 'group' in API :id/share, and in GroupLinks::CreateService
  belongs_to :shared_with_group, class_name: 'Group', foreign_key: :shared_with_group_id

  validates :shared_group, presence: true
  validates :shared_group_id, uniqueness: { scope: [:shared_with_group_id],
                                            message: _('The group has already been shared with this group') }
  validates :shared_with_group, presence: true
  validates :group_access, inclusion: { in: Gitlab::Access.all_values },
                           presence: true

  scope :non_guests, -> { where('group_access > ?', Gitlab::Access::GUEST) }
  scope :public_or_visible_to_user, ->(group, user) { where(shared_with_group: group, shared_group: Group.public_or_visible_to_user(user)) } # rubocop:disable Cop/GroupPublicOrVisibleToUser

  def self.access_options
    Gitlab::Access.options_with_owner
  end

  def self.default_access
    Gitlab::Access::DEVELOPER
  end

  def human_access
    Gitlab::Access.human_access(self.group_access)
  end
end
