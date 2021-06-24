# frozen_string_literal: true
module RestrictedSignup
  extend ActiveSupport::Concern

  private

  def error_for_signup(email)
    if denied_domain?(email)
      return 'is not from an allowed domain.'
    end

    unless allowed_domain?(email)
      return "domain is not authorized for sign-up."
    end

    nil
  end

  def error_for_restriction(email)
    return unless email_restrictions_for?(email)

    'is not allowed. Try again with a different email address, or contact your GitLab admin.'
  end

  def signup_domain_valid_for?(email)
    (!denied_domain?(email) && allowed_domain?(email))
  end

  def denied_domain?(email)
    if Gitlab::CurrentSettings.domain_denylist_enabled?
      blocked_domains = Gitlab::CurrentSettings.domain_denylist
      return true if domain_matches?(blocked_domains, email)
    end

    false
  end

  def allowed_domain?(email)
    allowed_domains = Gitlab::CurrentSettings.domain_allowlist
    unless allowed_domains.blank?
      return domain_matches?(allowed_domains, email)
    end

    true
  end

  def domain_matches?(email_domains, email)
    signup_domain = Mail::Address.new(email).domain
    email_domains.any? do |domain|
      escaped = Regexp.escape(domain).gsub('\*', '.*?')
      regexp = Regexp.new "^#{escaped}$", Regexp::IGNORECASE
      signup_domain =~ regexp
    end
  end

  def email_restrictions_for?(email)
    return false unless Gitlab::CurrentSettings.email_restrictions_enabled?

    restrictions = Gitlab::CurrentSettings.email_restrictions
    return false if restrictions.blank?

    Gitlab::UntrustedRegexp.new(restrictions).match?(email)
  end
end
