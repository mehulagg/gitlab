# frozen_string_literal: true

class LabelPriority < NamespaceShard
  include Importable

  belongs_to :project
  belongs_to :label

  validates :label, presence: true, unless: :importing?
  validates :project, :priority, presence: true
  validates :label_id, uniqueness: { scope: :project_id }
  validates :priority, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
