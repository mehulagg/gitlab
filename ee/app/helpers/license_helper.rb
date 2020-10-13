# frozen_string_literal: true

module LicenseHelper
  include ActionView::Helpers::AssetTagHelper
  include ActionView::Helpers::UrlHelper

  delegate :new_admin_license_path, to: 'Gitlab::Routing.url_helpers'

  def current_active_user_count
    License.current&.current_active_users_count || active_user_count
  end

  def maximum_user_count
    License.current&.maximum_user_count || 0
  end

  def seats_calculation_message(license)
    return unless license.present?
    return unless license.exclude_guests_from_active_count?

    s_("Users with a Guest role or those who don't belong to a Project or Group will not use a seat from your license.")
  end

  def current_license_title
    License.current&.plan&.titleize || 'Core'
  end

  def new_trial_url
    return_to_url = CGI.escape(Gitlab.config.gitlab.url)
    uri = URI.parse(::EE::SUBSCRIPTIONS_URL)
    uri.path = '/trials/new'
    uri.query = "return_to=#{return_to_url}&id=#{Base64.strict_encode64(current_user.email)}"
    uri.to_s
  end

  def show_promotions?(selected_user = current_user)
    return false unless selected_user

    if Gitlab::CurrentSettings.current_application_settings
      .should_check_namespace_plan?
      true
    else
      license = License.current
      license.nil? || license.expired?
    end
  end

  def show_advanced_search_promotion?
    !Gitlab::CurrentSettings.should_check_namespace_plan? && show_promotions? && show_callout?('promote_advanced_search_dismissed') && !License.feature_available?(:elastic_search)
  end

  extend self

  private

  def active_user_count
    License.current_active_users.count
  end
end
