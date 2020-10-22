# frozen_string_literal: true

module Members
  class InviteService < Members::BaseService
    DEFAULT_LIMIT = 100

    def execute(source)
      return error(s_('Email cannot be blank')) if params[:email].blank?

      emails = params[:email].split(',').uniq.flatten

      return error(s_("Too many users specified (limit is %{user_limit})") % { user_limit: user_limit }) if
        user_limit && emails.size > user_limit

      errors = {}

      emails.each do |email|
        existing_member = source.members.includes(:user).where(users: { email: email} )
        if existing_member.present?
          errors[email] = "Already a member of #{source.name}"
          next
        end

        existing_invite = source.members.find_by(invite_email: email)
        if existing_invite.present?
          errors[email] = "Member already invited to #{source.name}"
          next
        end

        existing_user = User.find_by(email: email)
        if existing_user.present?
          new_member = create_member(current_user, existing_user, source, params.merge({ invite_email: email }))
          if !(new_member.valid? && new_member.persisted?)
            errors[email] = new_member.errors.full_messages.to_sentence
          end
          next
        end

        new_invite = invite_member(current_user, source, params)
        if !(new_invite.valid? && new_invite.persisted?)
          current_error =
            # Invited users may not have an associated user
            if new_invite.user.present?
              "#{new_invite.user.username}: "
            else
              ""
            end

          current_error += new_invite.errors.full_messages.to_sentence
          errors[email] = current_error
          next
        end
      end

      return success unless errors.any?

      error(errors)
    end

    private

    def invite_member(current_user, source, params)
     (source.class.name + 'Member').constantize.create(source_id: source.id,
       user_id: nil,
       access_level: params[:access_level],
       invite_email: params[:email],
       created_by_id: current_user.id,
       expires_at: params[:expires_at],
       requested_at: Time.current.utc)
    end

    def create_member(current_user, user, source, params)
      source.add_user(user, params[:access_level], current_user: current_user, expires_at: params[:expires_at])
    end

    def user_limit
      limit = params.fetch(:limit, DEFAULT_LIMIT)

      limit && limit < 0 ? nil : limit
    end
  end
end
