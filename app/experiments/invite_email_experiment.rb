# frozen_string_literal: true

class InviteEmailExperiment < ApplicationExperiment
  segment :member_user, variant: :avatar

  def control_behavior(subject_line)
    mail_invite_standard(subject_line)
  end

  def avatar_behavior(subject_line)
    mail_invite_with_avatar(subject_line)
  end

  private

  def member_user
    context.actor
  end
end
