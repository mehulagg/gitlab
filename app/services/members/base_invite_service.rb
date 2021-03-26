# frozen_string_literal: true

module Members
  class BaseInviteService < Members::BaseService
    BlankInvitesError = Class.new(StandardError)
    TooManyInvitesError = Class.new(StandardError)

    DEFAULT_INVITE_LIMIT = 100

    def execute(source)
      @source = source
      validate_invites!

      ::Member.transaction do
        invites.each(&method(:process_invite))
      end

      enqueue_onboarding_progress_action
      result
    rescue BlankInvitesError, TooManyInvitesError => e
      error(e.message)
    end

    private

    attr_reader :source, :errors, :invites, :successfully_created_namespace_id

    def process_invite(_invite)
      # no-op
    end

    def validate_invites!
      raise BlankInvitesError, s_('AddMember|No users specified.') if invites.blank?

      if user_limit && invites.size > user_limit
        raise TooManyInvitesError, s_("AddMember|Too many users specified (limit is %{user_limit})") % { user_limit: user_limit }
      end
    end

    def user_limit
      limit = params.fetch(:limit, DEFAULT_INVITE_LIMIT)

      limit && limit < 0 ? nil : limit
    end

    def enqueue_onboarding_progress_action
      return unless successfully_created_namespace_id

      Namespaces::OnboardingUserAddedWorker.perform_async(successfully_created_namespace_id)
    end

    def result
      if errors.any?
        error(formatted_errors)
      else
        success
      end
    end
  end
end

Members::BaseInviteService.prepend_if_ee('EE::Members::BaseInviteService')
