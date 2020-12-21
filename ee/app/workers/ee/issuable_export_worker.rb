# frozen_string_literal: true
module EE
  # PostReceive EE mixin
  #
  # This module is intended to encapsulate EE-specific model logic
  # and be prepended in the `IssuableExportCsvWorker` worker
  module IssuableExportCsvWorker # rubocop:disable Scalability/IdempotentWorker
    extend ::Gitlab::Utils::Override
    EE_PERMITTED_TYPES = %i(requirements).freeze

    private

    override :find_objects
    def find_objects(type, user, params)
      if type == :requirement
        ::RequirementsManagement::RequirementsFinder.new(user, params).execute
      else
        super
      end
    end

    override :service
    def service(issuables, type, project)
      if type == :requirement
        ::RequirementsManagement::ExportCsvService.new(issuables, project)
      else
        super
      end
    end

    override :check_permitted_type!
    def check_permitted_type!(type)
      raise ArgumentError, "type parameter must be :issue, :merge_request, or :requirements, it was #{type}" unless PERMITTED_TYPES.include?(type)
    end

    override :permitted_issuable_types
    def permitted_issuable_types
      super + EE_PERMITTED_TYPES
    end
  end
end
