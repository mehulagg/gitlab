# frozen_string_literal: true

module EE::Gitlab::Rack::Attack
  Rack::Attack.throttle('throttle_incident_management_notification_web', EE::Gitlab::Throttle.incident_management_options) do |req|
    next unless req.web_request?
    next unless EE::Gitlab::Throttle.settings.throttle_incident_management_notification_enabled

    route = req.route_params
    action = "#{route[:controller]}##{route[:action]}"
    throttled_actions = [
      'projects/alerting/notifications#create',
      'projects/prometheus/alerts#notify'
    ]

    next unless throttled_actions.include?(action)

    req.path
  end
end
