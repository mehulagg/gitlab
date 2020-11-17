# frozen_string_literal: true

class IndexStatus < ApplicationRecord
  include ::ShaAttribute

  belongs_to :project

  sha_attribute :last_wiki_commit

  validates :project_id, presence: true

  scope :for_project, ->(project_id) { where(project_id: project_id) }
end
