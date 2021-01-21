# frozen_string_literal: true

module EE
  module NamespacePolicy
    extend ActiveSupport::Concern

    prepended do
      condition(:over_storage_limit, scope: :subject) { @subject.over_storage_limit? }

      rule { admin & is_gitlab_com }.enable :update_subscription_limit

      rule { over_storage_limit }.policy do
        prevent :create_projects
      end
    end
  end
end
