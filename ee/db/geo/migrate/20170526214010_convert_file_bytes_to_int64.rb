# frozen_string_literal: true

class ConvertFileBytesToInt64 < ActiveRecord::Migration[4.2]
  def change
    change_column :file_registry, :bytes, :integer, limit: 8
  end
end
