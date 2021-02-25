# frozen_string_literal: true

class AddCompanyNameToUserPreferences < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  # rubocop:disable Migration/AddLimitToTextColumns
  # limit is added in 20210225132323_add_text_limit_to_user_preferences_company_name
  def change
    add_column :user_preferences, :company_name, :text, null: true
  end
  # rubocop:enable Migration/AddLimitToTextColumns
end
