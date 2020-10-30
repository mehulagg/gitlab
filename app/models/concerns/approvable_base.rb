# frozen_string_literal: true

module ApprovableBase
  extend ActiveSupport::Concern
  include FromUnion

  included do
    has_many :approvals, dependent: :delete_all # rubocop:disable Cop/ActiveRecordDependent
    has_many :approved_by_users, through: :approvals, source: :user

    scope :without_approvals, -> { left_outer_joins(:approvals).where(approvals: { id: nil }) }
    scope :with_approvals, -> { joins(:approvals) }

    scope :approved_by_users_with_ids, -> (*user_ids) do
      user_ids.reduce(all) do |items, user_id|
        items.where('EXISTS (?)',
          Approval
            .select(1)
            .where(
              Approval.arel_table[:merge_request_id].eq(MergeRequest.arel_table[:id])
                .and(Approval.arel_table[:user_id].eq(user_id))
            )
        )
      end
    end

    scope :approved_by_users_with_usernames, -> (*usernames) do
      usernames.reduce(all) do |items, username|
        items.where('EXISTS (?)',
          Approval
            .select(1)
            .joins(:user)
            .where(
              Approval.arel_table[:merge_request_id].eq(MergeRequest.arel_table[:id])
                .and(User.arel_table[:username].eq(username))
            )
        )
      end
    end
  end

  class_methods do
    def select_from_union(relations)
      where(id: from_union(relations))
    end
  end

  def approved_by?(user)
    return false unless user

    approved_by_users.include?(user)
  end

  def can_be_approved_by?(user)
    user && !approved_by?(user) && user.can?(:approve_merge_request, self)
  end
end
