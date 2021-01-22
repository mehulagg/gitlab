# frozen_string_literal: true
module EE
  # PostReceive EE mixin
  #
  # This module is intended to encapsulate EE-specific model logic
  # and be prepended in the `IssuableExportCsvWorker` worker
  module IssuableExportCsvWorker # rubocop:disable Scalability/IdempotentWorker
    extend ::Gitlab::Utils::Override

    private

    override :service_classes_for
    def service_classes_for(type)
      return super unless type == :requirement

      { finder: ::RequirementsManagement::RequirementsFinder, service: ::RequirementsManagement::ExportCsvService }
    end

    override :type_error_message
    def type_error_message(type)
      "Type parameter must be :issue, :merge_request, or :requirements, it was #{type}"
    end
  end
end
