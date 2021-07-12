# frozen_string_literal: true

class AddLabelAppliedToIssuableSla < ActiveRecord::Migration[6.1]
  def change
    add_column :issuable_slas, :label_applied, :boolean, default: false
  end
end
