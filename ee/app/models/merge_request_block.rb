# frozen_string_literal: true

class MergeRequestBlock < ApplicationRecord
  belongs_to :blocking_merge_request, class_name: 'MergeRequest'
  belongs_to :blocked_merge_request, class_name: 'MergeRequest'

  DEPENDENCY_TREE_LIMIT = 100

  validates_presence_of :blocking_merge_request
  validates_presence_of :blocked_merge_request
  validates_uniqueness_of :blocked_merge_request, scope: :blocking_merge_request

  validate :check_block_constraints

  scope :with_blocking_mr_ids, -> (ids) do
    where(blocking_merge_request_id: ids).includes(:blocking_merge_request)
  end

  private

  def check_block_constraints
    return unless blocking_merge_request && blocked_merge_request

    errors.add(:base, _('This block is self-referential')) if
      blocking_merge_request == blocked_merge_request

    check_circular_dependency_upwards(blocked_merge_request, blocking_merge_request, DEPENDENCY_TREE_LIMIT)
    check_circular_dependency_downwards(blocked_merge_request, blocking_merge_request, DEPENDENCY_TREE_LIMIT)
  end

  def check_circular_dependency_upwards(blocked_merge_request, blocking_merge_request, limit)
    if limit == 0
      errors.add(:blocked_merge_request, _('dependency tree is too deep'))
      return
    end

    blocking_merge_request.blocks_as_blockee.each do |block|
      if block.blocking_merge_request == blocked_merge_request
        errors.add(:blocked_merge_request, _('circular dependency'))
        return
      end

      check_circular_dependency_upwards(blocked_merge_request, block.blocking_merge_request, limit-1)
    end
  end

  def check_circular_dependency_downwards(blocked_merge_request, blocking_merge_request, limit)
    if limit == 0
      errors.add(:blocking_merge_request, _('dependency tree is too deep'))
      return
    end

    blocked_merge_request.blocks_as_blocker.each do |block|
      if block.blocked_merge_request == blocking_merge_request
        errors.add(:blocking_merge_request, _('circular dependency'))
        return
      end

      check_circular_dependency_downwards(block.blocked_merge_request, blocking_merge_request, limit-1)
    end
  end
end
