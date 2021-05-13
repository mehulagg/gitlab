# frozen_string_literal: true

class ProjectCustomAttribute < NamespaceShard
  belongs_to :project

  validates :project, :key, :value, presence: true
  validates :key, uniqueness: { scope: [:project_id] }
end
