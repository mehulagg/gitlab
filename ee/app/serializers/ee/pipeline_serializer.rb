# frozen_string_literal: true

module EE
  module PipelineSerializer
    extend ActiveSupport::Concern

    private

    def preloaded_relations
      relations = super

      project_relation = relations.detect { |item| item.is_a?(Hash) }
      project_relation[:project].push(:security_setting)
      relations
    end
  end
end
