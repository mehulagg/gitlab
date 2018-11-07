# frozen_string_literal: true

# Helper methods for per-User preferences
module PreferencesHelper
  prepend EE::PreferencesHelper

  def layout_choices
    [
        ['Fixed', :fixed],
        ['Fluid', :fluid]
    ]
  end

  # Maps `dashboard` values to more user-friendly option text
  DASHBOARD_CHOICES = {
    projects: _("Your Projects (default)"),
    stars:    _("Starred Projects"),
    project_activity: _("Your Projects' Activity"),
    starred_project_activity: _("Starred Projects' Activity"),
    groups: _("Your Groups"),
    todos: _("Your Todos"),
    issues: _("Assigned Issues"),
    merge_requests: _("Assigned Merge Requests"),
    operations: _("Operations Dashboard")
  }.with_indifferent_access.freeze

  # Returns an Array usable by a select field for more user-friendly option text
  def dashboard_choices
    dashboards = User.dashboards.keys

    validate_dashboard_choices!(dashboards)
    dashboards -= excluded_dashboard_choices

    dashboards.map do |key|
      # Use `fetch` so `KeyError` gets raised when a key is missing
      [DASHBOARD_CHOICES.fetch(key), key]
    end
  end

  def project_view_choices
    [
      ['Files and Readme (default)', :files],
      ['Activity', :activity],
      ['Readme', :readme]
    ]
  end

  def user_application_theme
    @user_application_theme ||= Gitlab::Themes.for_user(current_user).css_class
  end

  def user_color_scheme
    Gitlab::ColorSchemes.for_user(current_user).css_class
  end

  private

  # Ensure that anyone adding new options updates `DASHBOARD_CHOICES` too
  def validate_dashboard_choices!(user_dashboards)
    if user_dashboards.size != DASHBOARD_CHOICES.size
      raise "`User` defines #{user_dashboards.size} dashboard choices," \
        " but `DASHBOARD_CHOICES` defined #{DASHBOARD_CHOICES.size}."
    end
  end

  # List of dashboard choice to be excluded from CE.
  # EE would override this.
  def excluded_dashboard_choices
    ['operations']
  end
end
