# frozen_string_literal: true

module Members
  class CreateService < Members::BaseInviteService
    extend ::Gitlab::Utils::Override

    def initialize(*args)
      super

      @errors = []
      @invites = params[:user_ids]&.split(',')&.uniq&.flatten
    end

    private

    override :process_invite
    def process_invite(invite)
      add_member(invite)
    end

    def add_member(invite)
      invite = parse_invite(invite)
      new_member = source.add_user(invite, params[:access_level], current_user: current_user, expires_at: params[:expires_at])

      if new_member.invalid?
        prefix = ''
        prefix += "#{new_member.user.username}: " if new_member.user.present?

        errors << prefix + new_member.errors.full_messages.to_sentence
      else
        after_execute(member: new_member)
        @successfully_created_namespace_id ||= source.is_a?(Project) ? source.namespace_id : source.id
      end
    end

    def parse_invite(invite)
      return invite unless invite.match?(/\A\d+\Z/)

      invite.to_i
    end

    def formatted_errors
      errors.to_sentence
    end
  end
end
