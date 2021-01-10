# frozen_string_literal: true

# SpamCheckMethods
#
# Provide helper methods for checking if a given spammable object has
# potential spam data.
#
# Dependencies:
# - params with :request

module SpamCheckMethods
  # Removes spam/recaptcha related entries from params, and stores them as instance variables
  # on the current object. This is a necessary first step in order for subsequent service-specific
  # params validation to not fail because they attempt to use these parameters to create
  # or update model attributes.
  def filter_spam_check_params
    # rubocop:disable Gitlab/ModuleWithInstanceVariables
    @request            = params.delete(:request)
    @api                = params.delete(:api)
    @recaptcha_verified = params.delete(:recaptcha_verified)
    @spam_log_id        = params.delete(:spam_log_id)
    # rubocop:enable Gitlab/ModuleWithInstanceVariables
  end

  # Performs the spam checking of a Spammable via the SpamActionService, using the instance
  # variables previously stored out of params by #filter_spam_check_params.
  #
  # Modifies the spammable argument to set relevant attributes and errors.
  #
  # Returns a hash of fields which are required by the GraphQL mutation resolver to populate the
  # response fields which support the client-side GraphQL spam/recaptcha workflow.
  #
  # The spammable must be a dirty instance, which means it should be already assigned with the
  # new attribute values.
  def spam_check(spammable, user, action:)
    raise ArgumentError.new('Please provide an action, such as :create') unless action

    # rubocop:disable Gitlab/ModuleWithInstanceVariables
    Spam::SpamActionService.new(
      spammable: spammable,
      request: @request,
      user: user,
      context: { action: action }
    ).execute(
      api: @api,
      recaptcha_verified: @recaptcha_verified,
      spam_log_id: @spam_log_id)
    # rubocop:enable Gitlab/ModuleWithInstanceVariables

    {
      spam: spammable.spam?,
      needs_recaptcha_response: render_recaptcha?(spammable),
      spam_log_id: spammable.spam_log&.id,
      recaptcha_site_key: Gitlab::CurrentSettings.recaptcha_site_key
    }
  end

  private

  def render_recaptcha?(_spammable)
    # TODO: This is an unused placeholder for the actual logic, which will be refactored out of
    #   spammable_actions.rb into a shared module in a prerequisite MR.
    false
  end
end
