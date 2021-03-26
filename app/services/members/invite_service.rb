# frozen_string_literal: true

module Members
  class InviteService < Members::BaseInviteService
    extend ::Gitlab::Utils::Override

    def initialize(*args)
      super

      @errors = {}
      @invites = params[:email]&.split(',')&.uniq&.flatten
    end

    private

    alias_method :formatted_errors, :errors

    override :process_invite
    def process_invite(invite)
      return if existing_member?(invite)
      return if existing_invite?(invite)
      return if existing_request?(invite)

      add_member(invite)
    end

    def existing_member?(email)
      existing_member = source.members.with_user_by_email(email).exists?

      if existing_member
        errors[email] = s_("AddMember|Already a member of %{source_name}") % { source_name: source.name }
        return true
      end

      false
    end

    def existing_invite?(email)
      existing_invite = source.members.search_invite_email(email).exists?

      if existing_invite
        errors[email] = s_("AddMember|Member already invited to %{source_name}") % { source_name: source.name }
        return true
      end

      false
    end

    def existing_request?(email)
      existing_request = source.requesters.with_user_by_email(email).exists?

      if existing_request
        errors[email] = s_("AddMember|Member cannot be invited because they already requested to join %{source_name}") % { source_name: source.name }
        return true
      end

      false
    end

    def add_member(email)
      new_member = source.add_user(email, params[:access_level], current_user: current_user, expires_at: params[:expires_at])

      if new_member.invalid?
        errors[email] = new_member.errors.full_messages.to_sentence
      else
        after_execute(member: new_member)
        @successfully_created_namespace_id ||= source.is_a?(Project) ? source.namespace_id : source.id
      end
    end
  end
end
