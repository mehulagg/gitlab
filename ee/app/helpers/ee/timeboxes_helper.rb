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

    def data_warning_for(burndown)
      return unless burndown

      message =
        if burndown.empty?
          "The burndown chart can’t be shown, as all issues assigned to this milestone were closed on an older GitLab version before data was recorded. "
        elsif !burndown.accurate?
          "Some issues can’t be shown in the burndown chart, as they were closed on an older GitLab version before data was recorded. "
        end

      if message
        link = link_to "About burndown charts", help_page_path('user/project/milestones/burndown_charts.md'), class: 'burndown-docs-link'

        content_tag(:div, (message + link).html_safe, id: "data-warning", class: "settings-message prepend-top-20")
      end
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
