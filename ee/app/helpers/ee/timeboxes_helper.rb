# frozen_string_literal: true

module EE
  module TimeboxesHelper
    def can_generate_chart?(milestone)
      return false unless milestone.supports_milestone_charts?

      milestone.start_date.present? && milestone.due_date.present?
    end

    def show_burndown_charts_promotion?(milestone)
      milestone.is_a?(EE::Milestone) && !milestone.supports_milestone_charts? && show_promotions?
    end

    def show_burndown_placeholder?(milestone)
      milestone.supports_milestone_charts? &&
        can?(current_user, :admin_milestone, milestone.resource_parent)
    end

    def milestone_weight_tooltip_text(weight)
      if weight == 0
        _("Weight")
      else
        _("Weight %{weight}") % { weight: weight }
      end
    end

    def first_resource_state_event
      strong_memoize(:first_resource_state_event) { ::ResourceStateEvent.first }
    end

    def legacy_milestone?(milestone)
      first_resource_state_event && milestone.created_at < first_resource_state_event.created_at
    end
  end
end
