# frozen_string_literal: true

class AddVerificationFailureLimitToPagesDeployments < ActiveRecord::Migration[6.1]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  CONSTRAINT_NAME = 'pages_deployments_verification_failure_text_limit'

  def up
    add_text_limit :pages_deployments, :verification_failure, 255, constraint_name: CONSTRAINT_NAME
  end

  def down
    remove_check_constraint(:pages_deployments, CONSTRAINT_NAME)
  end
end
