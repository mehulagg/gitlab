# frozen_string_literal: true

module Members
  class InviteService < Members::BaseService
    DEFAULT_LIMIT = 100

    attr_reader :errors

    def initialize(current_user, params)
      @current_user, @params = current_user, params.dup
      @errors = {}
    end

    def execute(source)
      return error(s_('Email cannot be blank')) if params[:email].blank?

      emails = params[:email].split(',').uniq.flatten

      if user_limit && emails.size > user_limit
        return error(s_("Too many users specified (limit is %{user_limit})") % { user_limit: user_limit })
      end

      @source = source

      emails.each do |email|
        next if existing_member?(email)
        next if existing_invite?(email)
        next if existing_request?(email)

        if existing_user?(email)
          add_existing_user_as_member(email)
          next
        end

        invite_new_member_and_user(email)
      end

      return success unless errors.any?

      error(errors)
    end

    private

    attr_reader :source

    def invite_new_member_and_user(email)
      new_member = (source.class.name + 'Member').constantize.create(source_id: source.id,
        user_id: nil,
        access_level: params[:access_level],
        invite_email: email,
        created_by_id: current_user.id,
        expires_at: params[:expires_at])

      unless new_member.valid? && new_member.persisted?
        errors[params[:email]] = new_member.errors.full_messages.to_sentence
      end
    end

    def add_existing_user_as_member(email)
      new_member = create_member(existing_user(email))

      unless new_member.valid? && new_member.persisted?
        errors[email] = new_member.errors.full_messages.to_sentence
      end
    end

    def create_member(user)
      source.add_user(user, params[:access_level], current_user: current_user, expires_at: params[:expires_at])
    end

    def user_limit
      limit = params.fetch(:limit, DEFAULT_LIMIT)

      limit < 0 ? nil : limit
    end

    def existing_member?(email)
      existing_member = source.members.with_user_by_email(email).exists?

      if existing_member
        errors[email] = "Already a member of #{source.name}"
        return true
      end

      false
    end

    def existing_invite?(email)
      existing_invite = source.members.search_invite_email(email).exists?

      if existing_invite
        errors[email] = "Member already invited to #{source.name}"
        return true
      end

      false
    end

    def existing_request?(email)
      existing_request = source.requesters.with_user_by_email(email).exists?

      if existing_request
        errors[email] = "Member cannot be invited because they already requested to join #{source.name}"
        return true
      end

      false
    end

    def existing_user(email)
      User.find_by_email(email)
    end

    def existing_user?(email)
      existing_user(email).present?
    end
  end
end
