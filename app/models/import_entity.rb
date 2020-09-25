# frozen_string_literal: true

class ImportEntity < ApplicationRecord
  belongs_to :bulk_import, optional: false
  belongs_to :parent, class_name: 'ImportEntity', optional: true

  belongs_to :project, optional: true
  belongs_to :group, foreign_key: :namespace_id, optional: true

  validates :project, absence: true, if: :group
  validates :group, absence: true, if: :project
  validates :type, :source_full_path, :destination_name, :destination_full_path, presence: true

  validate :parent_is_a_group, if: :parent

  enum type: { group_import: 0, project_import: 1 }

  def parent_is_a_group
    unless parent.group_import?
      errors.add(:parent, 'must be a group')
    end
  end
end
