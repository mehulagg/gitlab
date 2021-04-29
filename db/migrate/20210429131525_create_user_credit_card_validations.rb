# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class CreateUserCreditCardValidations < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    with_lock_retries do
      create_table :user_credit_card_validations, id: false do |t|
        t.references :user, foreign_key: { on_delete: :cascade }, index: true, null: false
        t.timestamp :credit_card_validated_at, null: false
      end
    end
  end

  def down
    with_lock_retries do
      drop_table :user_credit_card_validations
    end
  end
end
