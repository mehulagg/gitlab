# frozen_string_literal: true

module AcceptsPendingInvitations
  extend ActiveSupport::Concern

  def accept_pending_invitations
    return unless resource.active_for_authentication? # this one is nil in the test

    if resource.accept_pending_invitations!.any?
      clear_stored_location_for_resource
      track_invite_acceptance
    end
  end

  def track_invite_acceptance
    # caveat - if invited multiple times to different projects, only the one clicked will count
    member_id = session.delete(:originating_member_id)
    invite_type = session.delete(:invite_type)

    return unless member_id && invite_type

    member = resource.members.id_in(member_id).first

    experiment('members/invite_email', actor: member).track(:accepted) if member && Members::InviteEmailExperiment.initial_invite_email?(invite_type)
  end

  def clear_stored_location_for_resource
    session_key = stored_location_key_for(resource)

    session.delete(session_key)
  end
end
