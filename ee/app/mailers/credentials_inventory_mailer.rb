# frozen_string_literal: true

class CredentialsInventoryMailer < ApplicationMailer
  helper EmailsHelper

  layout 'mailer'

  def personal_access_token_revoked(token:, revoked_by:)
    @revoked_by = revoked_by
    @token = token

    mail(
      to: token.user.notification_email,
      subject: _('Your Personal Access Token was revoked')
    )
  end

  def ssh_key_deleted(key:, deleted_by:)
    @deleted_by = deleted_by
    @key = key

    mail(
        to: key.user.notification_email,
        subject: _('Your SSH key was deleted')
    )
  end
end
