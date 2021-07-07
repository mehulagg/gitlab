# frozen_string_literal: true

module IncidentManagement
  class EscalationRulesFinder
    def initialize(project, params = {})
      @project = project
      @params = params
    end

    def execute
      rules = IncidentManagement::EscalationRule.for_project(project)

      by_min_elapsed_time(rules)
    end

    private

    attr_reader :project, :params

    def by_min_elapsed_time(rules)
      return rules unless params[:min_elapsed_time]

      rules.with_elapsed_time_over(params[:min_elapsed_time])
    end
  end
end
