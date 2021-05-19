# frozen_string_literal: true

class RemoveNotNullFromCcValidations < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  def up
    remove_not_null_constraint :user_credit_card_validations, :credit_card_validated_at
  end

  def down
    add_not_null_constraint :user_credit_card_validations, :credit_card_validated_at
  end
end
