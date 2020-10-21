# frozen_string_literal: true

module AutoRollbackHelper
  def auto_rollback_enabled?(project)
    project.auto_rollback_feature_available?
  end
end
