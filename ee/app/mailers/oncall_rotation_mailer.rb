# frozen_string_literal: true
module IncidentManagement
  class OncallRotationMailer < ApplicationMailer
    helper EmailsHelper

    layout 'mailer'

    def user_removed_from_rotation_email(user, rotation, recipients)
      @user = user
      @rotation = rotation
      @schedule = rotation.schedule
      @project = rotation.project

      mail(
        to: recipients.map(&:email),
        subject: "User removed from On-call rotation"
      )
    end
  end
end
