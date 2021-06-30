# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddCustomersDotJwtSigningKeyToApplicationSettings < ActiveRecord::Migration[6.1]
  DOWNTIME = false

  def change
    add_column :application_settings, :encrypted_customers_dot_jwt_signing_key, :text
    add_column :application_settings, :encrypted_customers_dot_jwt_signing_key_iv, :text
  end
end
