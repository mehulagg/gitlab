# frozen_string_literal: true

module EE
  module Issues
    module ExportCsvService
      extend ::Gitlab::Utils::Override
      include ::Gitlab::Utils::StrongMemoize

      override :associations_to_preload
      def associations_to_preload
        return super unless epics_available?

        super << :epic
      end

      override :header_to_value_hash
      def header_to_value_hash
        return super unless epics_available?

        super.merge({
          'Epic ID' => -> (issue) { issue.epic&.id },
          'Epic Title' => -> (issue) { issue.epic&.title }
        })
      end

      def epics_available?
        strong_memoize(:epics_available) do
          project.group&.feature_available?(:epics)
        end
      end
    end
  end
end
