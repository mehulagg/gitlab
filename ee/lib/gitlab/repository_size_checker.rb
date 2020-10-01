# frozen_string_literal: true

module Gitlab
  module RepositorySizeChecker
    extend ActiveSupport::Concern
    extend ::Gitlab::Utils::Override

    # included do
    #   extend ::Gitlab::Utils::Override
    # end

    override :parse_report
    def above_size_limit?
      return false unless enabled?

      if additional_repo_storage_available?
        total_repository_size_excess > additional_purchased_storage && current_size > limit
      else
        super
      end
    end

    override :parse_report
    # @param change_size [int] in bytes
    def exceeded_size(change_size = 0)
      exceeded_size = super

      if additional_repo_storage_available?
        exceeded_size += total_repository_size_excess - additional_purchased_storage
      end

      exceeded_size
    end

    private

    def additional_repo_storage_available?
      return false unless Gitlab.dev_env_or_com?
      return false unless Gitlab::CurrentSettings.enforce_namespace_storage_limit?

      Feature.enabled?(:additional_repo_storage_by_namespace)
    end
  end
end
