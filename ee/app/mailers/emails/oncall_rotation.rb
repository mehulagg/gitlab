# frozen_string_literal: true

module Emails
  module OncallRotation
    extend ActiveSupport::Concern

    def user_removed_from_rotation_email(user, rotation, recipients)
      @user = user
      @rotation = rotation
      @schedule = rotation.schedule
      @project = rotation.project

      mail(to: recipients.map(&:email), subject: subject('User removed from On-call rotation')) do |format|
        format.html { render layout: 'mailer' }
        format.text { render layout: 'mailer' }
      end
    end
  end
end
