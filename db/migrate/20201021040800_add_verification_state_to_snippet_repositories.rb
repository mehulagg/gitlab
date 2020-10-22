# frozen_string_literal: true

class AddVerificationStateToSnippetRepositories < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def change
    # Apparently we should not use NOT NULL for a new column
    # https://gitlab.com/gitlab-org/gitlab/-/issues/38060
    # This field will be controlled by state machine code anyway, so
    # unintentional NULLs should be less likely.
    add_column :snippet_repositories, :verification_state, :integer, default: 0, limit: 2
    add_column :snippet_repositories, :verification_started_at, :datetime_with_timezone
  end
end
