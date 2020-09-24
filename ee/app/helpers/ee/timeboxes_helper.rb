# frozen_string_literal: true

module EE
  module TimeboxesHelper
    def burndown_chart(milestone)
      if milestone.supports_milestone_charts?
        issues = milestone.issues_visible_to_user(current_user)
        Burndown.new(issues, milestone.start_date, milestone.due_date)
      end
    end

    def can_generate_chart?(milestone, burndown)
      return false unless milestone.supports_milestone_charts?

      burndown&.valid? && !burndown&.empty?
    end

    def show_burndown_charts_promotion?(milestone)
      milestone.is_a?(EE::Milestone) && !milestone.supports_milestone_charts? && show_promotions?
    end

    def show_burndown_placeholder?(milestone, warning)
      return false if cookies['hide_burndown_message'].present?
      return false unless milestone.supports_milestone_charts?

      warning.nil? && can?(current_user, :admin_milestone, milestone.resource_parent)
    end

    def milestone_weight_tooltip_text(weight)
      if weight == 0
        _("Weight")
      else
        _("Weight %{weight}") % { weight: weight }
      end
    end
  end
end
