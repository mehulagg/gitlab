# frozen_string_literal: true

class AddTestTable < ActiveRecord::Migration[6.0]
  def change
    create_table :foo do |t|
      t.text :name
    end
  end
end
