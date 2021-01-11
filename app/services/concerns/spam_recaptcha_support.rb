# frozen_string_literal: true

# This concern contains common logic related to reCAPTCHA support which is used in
# both the services layer to support the GraphQL API (SpamCheckMethods) as well as
# the controller layer to support the REST API (SpammableActions)
module SpamRecaptchaSupport
  extend ActiveSupport::Concern

  include Gitlab::Utils::StrongMemoize
  include Recaptcha::Verify

  def ensure_spam_config_loaded!
    strong_memoize(:spam_config_loaded) do
      Gitlab::Recaptcha.load_configurations!
    end
  end

  def render_recaptcha?(spammable)
    return false unless Gitlab::Recaptcha.enabled?

    # If there are other errors than the recaptcha error, ensure they are all resolved first
    # before rendering the recaptcha
    return false if spammable.errors.count > 1

    # Return true if a previous spam_check has set the needs_recaptcha flag on the Spammable model
    spammable.needs_recaptcha?
  end

  # Calls the reCAPTCHA verify API via the recaptcha gem's #verify_recaptcha method.
  #
  # A spammable model object, which implements Spammable, must be passed as the first argument.
  #
  # If it is nil (as it will be in the case of a create action via a controller using SpammableActions), then
  # #verify_recaptcha will ignore it.
  #
  # The second argument is an optional recaptchaResponse string resulting from the user
  # solving a reCAPTCHA, which the web client displayed using a provided
  # recaptcha_site_key via the reCAPTCHA javascript API
  #
  # If it is nil (as it will be in the case of a form submitted to the REST API using SpammableActions), then
  # #verify_recaptcha will fall back to using params['g-recaptcha-response'].to_s from the form params.
  #
  # If the response is invalid or there are other errors, a relevant error will be added to the
  # model's errors, if the model was not nil.
  #
  # In some cases such as API errors, an exception may be thrown from the reCAPTCHA verification
  # process.
  #
  # The return value is a truthy or falsy value from the underlying #verify_recaptcha call,
  # which can be used to set the @recaptcha_verified instance variable needed by
  # SpamCheckMethods#spam_check
  def verify_spammable_recaptcha!(spammable = nil, recaptcha_response = nil)
    verify_recaptcha_options = {
      model: spammable,
      response: recaptcha_response
    }

    ensure_spam_config_loaded! && verify_recaptcha(verify_recaptcha_options)
  end
end
