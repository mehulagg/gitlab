# frozen_string_literal: true

class AddCalloutScopeToUserCallouts < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  # rubocop:disable Migration/AddLimitToTextColumns
  # limit is added in 20210324190516_add_text_limit_to_callout_scope_in_user_callouts.rb
  # per the suggestion here: https://docs.gitlab.com/ee/development/database/strings_and_the_text_data_type.html#add-a-text-column-to-an-existing-table
  def change
    add_column :user_callouts, :callout_scope, :text, null: false, default: ''
  end
  # rubocop:enable Migration/AddLimitToTextColumns
end
