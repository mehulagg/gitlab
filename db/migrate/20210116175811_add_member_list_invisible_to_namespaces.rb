# frozen_string_literal: true

class AddMemberListInvisibleToNamespaces < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def change
    add_column :namespaces, :member_list_invisible, :boolean
  end
end
