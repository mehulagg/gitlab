# frozen_string_literal: true

class RemoveNullConstraintFromSecurityFindings < ActiveRecord::Migration[6.1]
  def up
    change_column_null :security_findings, :project_fingerprint, true
  end

  def down
    change_column_null :security_findings, :project_fingerprint, false
  end
end
