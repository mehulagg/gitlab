# frozen_string_literal: true

module Members
  class Creator
    def initialize(source, user, access_level, **args)
      @source = source
      @user = user
      @access_level = parsed_access_level(access_level)
      @args = args
    end

    def execute
      find_or_build_member
      update_member

      member
    end

    private

    attr_reader :source, :user, :access_level, :member, :args

    def parsed_access_level(access_level)
      access_levels.fetch(access_level) { access_level.to_i }
    end

    def access_levels
      # no-op
    end

    def update_member
      return unless can_update_member?

      member.attributes = member_attributes

      if member.request?
        ::Members::ApproveAccessRequestService.new(current_user, # rubocop:disable CodeReuse/ServiceClass
                                                   access_level: access_level)
                                              .execute(
                                                member,
                                                skip_authorization: ldap,
                                                skip_log_audit_event: ldap
                                              )
      else
        member.save
      end
    end

    def current_user
      args[:current_user]
    end

    def find_or_build_member
      @user = retrieve_user

      @member = if user.is_a?(User)
                  if existing_members
                    existing_members[user.id] || source.members.build(user_id: user.id)
                  else
                    source.members_and_requesters.find_or_initialize_by(user_id: user.id)
                  end
                else
                  source.members.build(invite_email: user)
                end
    end

    def existing_members
      args[:existing_members]
    end

    def ldap
      args[:ldap]
    end

    # This method is used to find users that have been entered into the "Add members" field.
    # These can be the User objects directly, their IDs, their emails, or new emails to be invited.
    def retrieve_user
      case user
      when User
        user
      when Integer
        User.find_by(id: user)
      else
        User.find_by(email: user) || user
      end
    end

    def can_update_member?
      # no-op
    end

    # Populates the attributes of a member.
    #
    # This logic resides in a separate method so that EE can extend this logic,
    # without having to patch the `add_user` method directly.
    def member_attributes
      {
        created_by: member.created_by || current_user,
        access_level: access_level,
        expires_at: args[:expires_at]
      }
    end
  end
end

Members::Creator.prepend_mod_with('Members::Creator')
