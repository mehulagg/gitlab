# frozen_string_literal: true

class RemoveFileUploadsFromRegistry < ActiveRecord::Migration[4.2]
  # Previous to GitLab 10.1, GitLab would save attachments/avatars to the
  # wrong directory (/var/opt/gitlab/gitlab-rails/working). Destroy these
  # entries so they will be downloaded again.
  def up
    Geo::BaseRegistry.connection.execute("DELETE FROM file_registry WHERE file_type != 'lfs'")
  end
end
