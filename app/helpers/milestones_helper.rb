module MilestonesHelper
  def milestones_filter_path(opts = {})
    if @project
      project_milestones_path(@project, opts)
    elsif @group
      group_milestones_path(@group, opts)
    else
      dashboard_milestones_path(opts)
    end
  end

  def milestones_label_path(opts = {})
    if @project
      project_issues_path(@project, opts)
    elsif @group
      issues_group_path(@group, opts)
    else
      issues_dashboard_path(opts)
    end
  end

  def milestones_browse_issuables_path(milestone, state: nil, type:)
    opts = { milestone_title: milestone.title, state: state }

    if @project
      polymorphic_path([@project.namespace.becomes(Namespace), @project, type], opts)
    elsif @group
      polymorphic_url([type, @group], opts)
    else
      polymorphic_url([type, :dashboard], opts)
    end
  end

  def milestone_issues_by_label_count(milestone, label, state:)
    issues = milestone.issues.with_label(label.title)
    issues =
      case state
      when :opened
        issues.opened
      when :closed
        issues.closed
      else
        raise ArgumentError, "invalid milestone state `#{state}`"
      end

    issues.size
  end

  # Returns count of milestones for different states
  # Uses explicit hash keys as the 'opened' state URL params differs from the db value
  # and we need to add the total
  def milestone_counts(milestones)
    counts = milestones.reorder(nil).group(:state).count

    {
      opened: counts['active'] || 0,
      closed: counts['closed'] || 0,
      all: counts.values.sum || 0
    }
  end

  # Show 'active' class if provided GET param matches check
  # `or_blank` allows the function to return 'active' when given an empty param
  # Could be refactored to be simpler but that may make it harder to read
  def milestone_class_for_state(param, check, match_blank_param = false)
    if match_blank_param
      'active' if param.blank? || param == check
    elsif param == check
      'active'
    else
      check
    end
  end

  def milestone_progress_tooltip_text(milestone)
    has_issues = milestone.total_issues_count(current_user) > 0

    if has_issues
      [
        _('Progress'),
        _("%{percent} complete") % { percent: "#{milestone.percent_complete(current_user)}%" }
      ].join('<br />')
    else
      _('Progress')
    end
  end

  def milestone_progress_bar(milestone)
    options = {
      class: 'progress-bar progress-bar-success',
      style: "width: #{milestone.percent_complete(current_user)}%;"
    }

    content_tag :div, class: 'progress' do
      content_tag :div, nil, options
    end
  end

  def milestones_filter_dropdown_path
    project = @target_project || @project
    if project
      project_milestones_path(project, :json)
    elsif @group
      group_milestones_path(@group, :json)
    else
      dashboard_milestones_path(:json)
    end
  end

  # TODO: This should be renamed to be clearer amongst other tooltip helper methods
  def milestone_tooltip_title(milestone)
    if milestone.due_date
      [milestone.due_date.to_s(:medium), "(#{milestone_remaining_days(milestone)})"].join(' ')
    end
  end

  def milestone_time_for(date, date_type)
    title = date_type === :start ? "Start date" : "End date"

    if date
      time_ago = time_ago_in_words(date)
      time_ago.slice!("about ")

      time_ago << if date.past?
                    " ago"
                  else
                    " remaining"
                  end

      content = [
        title,
        "<br />",
        date.to_s(:medium),
        "(#{time_ago})"
      ].join(" ")

      content.html_safe
    else
      title
    end
  end

  def milestone_issues_tooltip_text(issues)
    if issues.any?
      content = []

      content.push(n_("1 open issue", "%d open issues", issues.opened.count) % issues.opened.count) if issues.opened.any?
      content.push(n_("1 closed issue", "%d closed issues", issues.closed.count) % issues.closed.count) if issues.closed.any?

      return content.join('<br />').html_safe
    end

    _("Issues")
  end

  def milestone_merge_requests_tooltip_text(merge_requests)
    if merge_requests.any?
      content = []

      content.push(n_("1 open merge request", "%d open merge requests", merge_requests.opened.count) % merge_requests.opened.count) if merge_requests.opened.any?
      content.push(n_("1 closed merge request", "%d closed merge requests", merge_requests.closed.count) % merge_requests.closed.count) if merge_requests.closed.any?
      content.push(n_("1 merged merge request", "%d merged merge requests", merge_requests.merged.count) % merge_requests.merged.count) if merge_requests.merged.any?

      return content.join('<br />').html_safe
    end

    _("Merge requests")
  end

  def milestone_remaining_days(milestone)
    if milestone.expired?
      content_tag(:strong, 'Past due')
    elsif milestone.upcoming?
      content_tag(:strong, 'Upcoming')
    elsif milestone.due_date
      time_ago = time_ago_in_words(milestone.due_date)
      content = time_ago.gsub(/\d+/) { |match| "<strong>#{match}</strong>" }
      content.slice!("about ")
      content << " remaining"
      content.html_safe
    elsif milestone.start_date && milestone.start_date.past?
      days    = milestone.elapsed_days
      content = content_tag(:strong, days)
      content << " #{'day'.pluralize(days)} elapsed"
      content.html_safe
    end
  end

  def milestone_date_range(milestone)
    if milestone.start_date && milestone.due_date
      "#{milestone.start_date.to_s(:medium)}–#{milestone.due_date.to_s(:medium)}"
    elsif milestone.due_date
      if milestone.due_date.past?
        "expired on #{milestone.due_date.to_s(:medium)}"
      else
        "expires on #{milestone.due_date.to_s(:medium)}"
      end
    elsif milestone.start_date
      if milestone.start_date.past?
        "started on #{milestone.start_date.to_s(:medium)}"
      else
        "starts on #{milestone.start_date.to_s(:medium)}"
      end
    end
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
      message += link_to "About burndown charts", help_page_path('user/project/milestones/index', anchor: 'burndown-charts'), class: 'burndown-docs-link'

      content_tag(:div, message.html_safe, id: "data-warning", class: "settings-message prepend-top-20")
    end
  end

  def can_generate_chart?(burndown)
    return unless @project.feature_available?(:burndown_charts, current_user) &&
        @project.feature_available?(:issue_weights, current_user)

    burndown&.valid? && !burndown&.empty?
  end

  def show_burndown_placeholder?(warning)
    return false if cookies['hide_burndown_message'].present?

    return false unless @project.feature_available?(:burndown_charts, current_user) &&
        @project.feature_available?(:issue_weights, current_user)

    warning.nil? && can?(current_user, :admin_milestone, @project)
  end

  def milestone_merge_request_tab_path(milestone)
    if @project
      merge_requests_project_milestone_path(@project, milestone, format: :json)
    elsif @group
      merge_requests_group_milestone_path(@group, milestone.safe_title, title: milestone.title, format: :json)
    else
      merge_requests_dashboard_milestone_path(milestone, title: milestone.title, format: :json)
    end
  end

  def milestone_participants_tab_path(milestone)
    if @project
      participants_project_milestone_path(@project, milestone, format: :json)
    elsif @group
      participants_group_milestone_path(@group, milestone.safe_title, title: milestone.title, format: :json)
    else
      participants_dashboard_milestone_path(milestone, title: milestone.title, format: :json)
    end
  end

  def milestone_labels_tab_path(milestone)
    if @project
      labels_project_milestone_path(@project, milestone, format: :json)
    elsif @group
      labels_group_milestone_path(@group, milestone.safe_title, title: milestone.title, format: :json)
    else
      labels_dashboard_milestone_path(milestone, title: milestone.title, format: :json)
    end
  end

  def group_milestone_route(milestone, params = {})
    params = nil if params.empty?

    if milestone.legacy_group_milestone?
      group_milestone_path(@group, milestone.safe_title, title: milestone.title, milestone: params)
    else
      group_milestone_path(@group, milestone.iid, milestone: params)
    end
  end

  def milestone_weight_tooltip_text(weight)
    if weight.zero?
      _("Weight")
    else
      _("Weight %{weight}") % { weight: weight }
    end
  end
end
