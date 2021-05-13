# frozen_string_literal: true

class ProjectAlias < NamespaceShard
  belongs_to :project

  validates :project, presence: true
  validates :name,
    presence: true,
    uniqueness: true,
    format: {
      with: ::Gitlab::PathRegex.project_path_format_regex,
      message: ::Gitlab::PathRegex.project_path_format_message
    }
end
