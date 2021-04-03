# frozen_string_literal: true

class ScimFinder
  include ::Gitlab::Utils::StrongMemoize

  attr_reader :group, :saml_provider

  UnsupportedFilter = Class.new(StandardError)

  def initialize(group)
    @group = group
    @saml_provider = group&.saml_provider
  end

  def search(params)
    return null_identity unless saml_provider&.enabled?
    return all_identities if unfiltered?(params)

    filter_identities(params)
  end

  private

  def null_identity
    ScimIdentity.none
  end

  def all_identities
    group.scim_identities
  end

  def unfiltered?(params)
    params[:filter].blank?
  end

  def filter_identities(params)
    parser = EE::Gitlab::Scim::ParamsParser.new(params)

    if eq_filter_on_extern_uid?(parser)
      by_extern_uid(parser.filter_params[:extern_uid])
    elsif eq_filter_on_username?(parser)
      identity = by_extern_uid(parser.filter_params[:username])
      return identity if identity.present?

      by_username(parser.filter_params[:username])
    else
      raise UnsupportedFilter
    end
  end

  def eq_filter_on_extern_uid?(parser)
    parser.filter_operator == :eq && parser.filter_params[:extern_uid].present?
  end

  def by_extern_uid(extern_uid)
    group.scim_identities.with_extern_uid(extern_uid)
  end

  def eq_filter_on_username?(parser)
    parser.filter_operator == :eq && parser.filter_params[:username].present?
  end

  def by_username(username)
    user = User.find_by_username(username)

    if !user && email?(username)
      user ||= User.find_by_any_email(username) || User.find_by_username(email_local_part(username))
    end

    group.scim_identities.for_user(user)
  end

  def email?(email)
    ::ValidateEmail.valid?(email)
  end

  def email_local_part(email)
    ::Mail::Address.new(email).local
  end
end
