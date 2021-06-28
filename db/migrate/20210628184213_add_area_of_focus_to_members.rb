# frozen_string_literal: true

class AddAreaOfFocusToMembers < ActiveRecord::Migration[6.1]
  # rubocop:disable Migration/AddLimitToTextColumns
  # limit is added in 20200501000002_add_text_limit_to_sprints_extended_title
  def change
    add_column :members, :area_of_focus, :text
  end
  # rubocop:enable Migration/AddLimitToTextColumns
end
