# frozen_string_literal: true

module TrackingHelper
  def tracking_attributes_by_object(object)
    case object
    when Project
      project_tracking_attrs
    when Group
      group_tracking_attrs
    when User
      user_profile_tracking_attrs
    else
      {}
    end
  end

  def project_tracking_attrs
    tracking_attrs('projects_side_navigation', 'render', 'projects_side_navigation')
  end

  def group_tracking_attrs
    tracking_attrs('groups_side_navigation', 'render', 'groups_side_navigation')
  end

  def user_profile_tracking_attrs
    tracking_attrs('user_side_navigation', 'render', 'user_side_navigation')
  end

  def tracking_attrs(label, event, property)
    return {} unless tracking_enabled?

    {
      data: {
        track_label: label,
        track_event: event,
        track_property: property
      }
    }
  end

  private

  def tracking_enabled?
    Rails.env.production? &&
      ::Gitlab::CurrentSettings.snowplow_enabled?
  end
end
