# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class BackfillIssueNamespaces < ActiveRecord::Migration[6.1]
  class Project < ActiveRecord::Base
    has_one :project_namespace
  end
  
  class Issue < ActiveRecord::Base
    belongs_to :project
  end

  def up
    # FIXME: naive approach
    Issue.includes(project: :project_namespace).find_each do |issue|
      issue.project_namespace_id = issue.project.project_namespace.id
      issue.save!
    end
  end

  def down
  end
end
