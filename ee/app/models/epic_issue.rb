# frozen_string_literal: true

class EpicIssue < ApplicationRecord
  include EpicTreeSorting
  include EachBatch

  validates :epic, :issue, presence: true
  validates :issue, uniqueness: true

  belongs_to :epic
  belongs_to :issue

  alias_attribute :parent_ids, :epic_id
  alias_attribute :parent, :epic

  scope :in_epic, ->(epic_id) { where(epic_id: epic_id) }
  scope :related_issues_for_batches, ->(epic_ids) { select(:id, :relative_position).where(epic_id: epic_ids) }

  validate :validate_confidential_epic

  def root_epic_tree_node?
    false
  end

  private

  def validate_confidential_epic
    return unless epic && issue

    if epic.confidential? && !issue.confidential?
      errors.add :issue, _('Cannot set confidential epic for a non-confidential issue')
    end
  end
end
