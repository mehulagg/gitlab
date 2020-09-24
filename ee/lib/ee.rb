# frozen_string_literal: true

module EE
  SUBSCRIPTIONS_URL = ENV.fetch('CUSTOMER_PORTAL_URL', 'https://customers.gitlab.com').freeze
  SUBSCRIPTIONS_COMPARISON_URL = "https://about.gitlab.com/pricing/gitlab-com/feature-comparison".freeze
  SUBSCRIPTIONS_MORE_MINUTES_URL = "#{SUBSCRIPTIONS_URL}/buy_pipeline_minutes".freeze
  SUBSCRIPTIONS_MORE_STORAGE_URL = "#{SUBSCRIPTIONS_URL}/buy_storage".freeze
  SUBSCRIPTIONS_PLANS_URL = "#{SUBSCRIPTIONS_URL}/plans".freeze
  SUBSCRIPTION_PORTAL_ADMIN_EMAIL = ENV.fetch('SUBSCRIPTION_PORTAL_ADMIN_EMAIL', 'gl_com_api@gitlab.com')
  SUBSCRIPTION_PORTAL_ADMIN_TOKEN = ENV.fetch('SUBSCRIPTION_PORTAL_ADMIN_TOKEN', 'customer_admin_token')
  CUSTOMER_SUPPORT_URL = 'https://support.gitlab.com'.freeze
  CUSTOMER_LICENSE_SUPPORT_URL = 'https://support.gitlab.com/hc/en-us/requests/new?ticket_form_id=360000071293'.freeze
end
