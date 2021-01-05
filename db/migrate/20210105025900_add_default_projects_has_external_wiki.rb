# frozen_string_literal: true

class AddDefaultProjectsHasExternalWiki < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def change
    change_column_default(:projects, :has_external_wiki, from: nil, to: false)
  end
end
