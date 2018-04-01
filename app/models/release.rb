class Release < ApplicationRecord
  include CacheMarkdownField

  cache_markdown_field :description

  belongs_to :project

  validates :description, :project, :tag, presence: true
end
