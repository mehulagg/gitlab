# frozen_string_literal: true

module EE
  SUBSCRIPTIONS_URL = ::Gitlab::SubscriptionPortal::SUBSCRIPTIONS_URL
  SUBSCRIPTIONS_COMPARISON_URL = "https://about.gitlab.com/pricing/gitlab-com/feature-comparison"
  SUBSCRIPTIONS_GRAPHQL_URL = "#{SUBSCRIPTIONS_URL}/graphql"
  SUBSCRIPTIONS_MORE_MINUTES_URL = "#{SUBSCRIPTIONS_URL}/buy_pipeline_minutes"
  SUBSCRIPTIONS_MORE_STORAGE_URL = "#{SUBSCRIPTIONS_URL}/buy_storage"
  SUBSCRIPTIONS_MANAGE_URL = "#{SUBSCRIPTIONS_URL}/subscriptions"
  SUBSCRIPTIONS_PLANS_URL = "#{SUBSCRIPTIONS_URL}/plans"
  SUBSCRIPTION_PORTAL_ADMIN_EMAIL = ENV.fetch('SUBSCRIPTION_PORTAL_ADMIN_EMAIL', 'gl_com_api@gitlab.com')
  SUBSCRIPTION_PORTAL_ADMIN_TOKEN = ENV.fetch('SUBSCRIPTION_PORTAL_ADMIN_TOKEN', 'customer_admin_token')
  CUSTOMER_SUPPORT_URL = 'https://support.gitlab.com'
  CUSTOMER_LICENSE_SUPPORT_URL = 'https://support.gitlab.com/hc/en-us/requests/new?ticket_form_id=360000071293'
  GITLAB_COM_STATUS_URL = "https://status.gitlab.com"
end
