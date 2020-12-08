# frozen_string_literal: true

module Gitlab
  module AlertManagement
    class AlertPayloadFieldExtractor
      def initialize(project)
        @project = project
      end

      def extract(payload)
        [
          ::AlertManagement::AlertPayloadField.new(
            project: project,
            path: 'foo.bar',
            label: 'Bar',
            type: 'string'
          )
        ]
      end

      private

      attr_reader :project
    end
  end
end
