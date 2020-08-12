# frozen_string_literal: true

# == EnforcesTwoFactorAuthentication
#
# Controller concern to enforce two-factor authentication requirements
#
# Upon inclusion, adds `check_two_factor_requirement` as a before_action,
# and makes `two_factor_grace_period_expired?` and `two_factor_skippable?`
# available as view helpers.
module EnforcesTwoFactorAuthentication
  extend ActiveSupport::Concern

  included do
    before_action :check_two_factor_requirement

    # to include this in controllers inheriting from `ActionController::Metal`
    # we need to add this block
    if respond_to?(:helper_method)
      helper_method :two_factor_grace_period_expired?, :two_factor_skippable?
    end
  end

  def check_two_factor_requirement
    return unless respond_to?(:current_user)

    if two_factor_authentication_required? && current_user_requires_two_factor?
      redirect_to profile_two_factor_auth_path
    end
  end

  def two_factor_authentication_required?
    Gitlab::CurrentSettings.require_two_factor_authentication? ||
      current_user.try(:require_two_factor_authentication_from_group?)
  end

  def current_user_requires_two_factor?
    current_user && !current_user.temp_oauth_email? && !current_user.two_factor_enabled? && !skip_two_factor?
  end

  # rubocop: disable CodeReuse/ActiveRecord
  def two_factor_authentication_reason(global: -> {}, group: -> {})
    if two_factor_authentication_required?
      if Gitlab::CurrentSettings.require_two_factor_authentication?
        global.call
      else
        groups = current_user.expanded_groups_requiring_two_factor_authentication.reorder(name: :asc)
        group.call(groups)
      end
    end
  end
  # rubocop: enable CodeReuse/ActiveRecord

  def two_factor_grace_period
    periods = [Gitlab::CurrentSettings.two_factor_grace_period]
    periods << current_user.two_factor_grace_period if current_user.try(:require_two_factor_authentication_from_group?)
    periods.min
  end

  def two_factor_grace_period_expired?
    date = current_user.otp_grace_period_started_at
    date && (date + two_factor_grace_period.hours) < Time.current
  end

  def two_factor_skippable?
    two_factor_authentication_required? &&
      !current_user.two_factor_enabled? &&
      !two_factor_grace_period_expired?
  end

  def skip_two_factor?
    session[:skip_two_factor] && session[:skip_two_factor] > Time.current
  end
end

EnforcesTwoFactorAuthentication.prepend_if_ee('EE::EnforcesTwoFactorAuthentication')
