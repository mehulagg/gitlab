# frozen_string_literal: true

module AuthHelper
  PROVIDERS_WITH_ICONS = %w(twitter github gitlab bitbucket google_oauth2 facebook azure_oauth2 authentiq salesforce atlassian_oauth2 openid_connect).freeze
  LDAP_PROVIDER = /\Aldap/.freeze

  def ldap_enabled?
    Gitlab::Auth::Ldap::Config.enabled?
  end

  def ldap_sign_in_enabled?
    Gitlab::Auth::Ldap::Config.sign_in_enabled?
  end

  def omniauth_enabled?
    Gitlab::Auth.omniauth_enabled?
  end

  def provider_has_custom_icon?(name)
    icon_for_provider(name.to_s)
  end

  def provider_has_builtin_icon?(name)
    PROVIDERS_WITH_ICONS.include?(name.to_s)
  end

  def provider_has_icon?(name)
    provider_has_builtin_icon?(name) || provider_has_custom_icon?(name)
  end

  def qa_class_for_provider(provider)
    {
      saml: 'qa-saml-login-button'
    }[provider.to_sym]
  end

  def auth_providers
    Gitlab::Auth::OAuth::Provider.providers
  end

  def label_for_provider(name)
    Gitlab::Auth::OAuth::Provider.label_for(name)
  end

  def icon_for_provider(name)
    Gitlab::Auth::OAuth::Provider.icon_for(name)
  end

  def form_based_provider_priority
    ['crowd', /^ldap/, 'kerberos']
  end

  def form_based_provider_with_highest_priority
    @form_based_provider_with_highest_priority ||= begin
      form_based_provider_priority.each do |provider_regexp|
        highest_priority = form_based_providers.find { |provider| provider.match?(provider_regexp) }
        break highest_priority unless highest_priority.nil?
      end
    end
  end

  def form_based_auth_provider_has_active_class?(provider)
    form_based_provider_with_highest_priority == provider
  end

  def form_based_provider?(name)
    [LDAP_PROVIDER, 'crowd'].any? { |pattern| pattern === name.to_s }
  end

  def form_based_providers
    auth_providers.select { |provider| form_based_provider?(provider) }
  end

  def any_form_based_providers_enabled?
    form_based_providers.any? { |provider| form_enabled_for_sign_in?(provider) }
  end

  def form_enabled_for_sign_in?(provider)
    return true unless provider.to_s.match?(LDAP_PROVIDER)

    ldap_sign_in_enabled?
  end

  def crowd_enabled?
    auth_providers.include? :crowd
  end

  def button_based_providers
    auth_providers.reject { |provider| form_based_provider?(provider) }
  end

  def display_providers_on_profile?
    button_based_providers.any?
  end

  def providers_for_base_controller
    auth_providers.reject { |provider| LDAP_PROVIDER === provider }
  end

  def enabled_button_based_providers
    disabled_providers = Gitlab::CurrentSettings.disabled_oauth_sign_in_sources || []

    providers = button_based_providers.map(&:to_s) - disabled_providers
    providers.sort_by do |provider|
      case provider
      when 'google_oauth2'
        0
      when 'github'
        1
      else
        2
      end
    end
  end

  def experiment_enabled_button_based_providers
    enabled_button_based_providers & %w(google_oauth2 github).freeze
  end

  def button_based_providers_enabled?
    enabled_button_based_providers.any?
  end

  def provider_image_tag(provider, size = 64)
    label = label_for_provider(provider)

    if provider_has_custom_icon?(provider)
      image_tag(icon_for_provider(provider), alt: label, title: "Sign in with #{label}")
    elsif provider_has_builtin_icon?(provider)
      file_name = "#{provider.to_s.split('_').first}_#{size}.png"

      image_tag("auth_buttons/#{file_name}", alt: label, title: "Sign in with #{label}")
    else
      label
    end
  end

  # rubocop: disable CodeReuse/ActiveRecord
  def auth_active?(provider)
    return current_user.atlassian_identity.present? if provider == :atlassian_oauth2

    current_user.identities.exists?(provider: provider.to_s)
  end
  # rubocop: enable CodeReuse/ActiveRecord

  def unlink_provider_allowed?(provider)
    IdentityProviderPolicy.new(current_user, provider).can?(:unlink)
  end

  def link_provider_allowed?(provider)
    IdentityProviderPolicy.new(current_user, provider).can?(:link)
  end

  def allow_admin_mode_password_authentication_for_web?
    current_user.allow_password_authentication_for_web? && !current_user.password_automatically_set?
  end

  def google_tag_manager_enabled?
    Gitlab.com? &&
      extra_config.has_key?('google_tag_manager_id') &&
      extra_config.google_tag_manager_id.present? &&
      !current_user
  end

  extend self
end

AuthHelper.prepend_if_ee('EE::AuthHelper')

# The methods added in EE should be available as both class and instance
# methods, just like the methods provided by `AuthHelper` itself.
AuthHelper.extend_if_ee('EE::AuthHelper')
