# frozen_string_literal: true

class CiMinutesUsageMailer < ApplicationMailer
  helper EmailsHelper

  layout 'mailer'

  def notify(namespace, recipients)
    @namespace = namespace

    mail(
      bcc: recipients,
      subject: "Action required: There are no remaining Pipeline minutes for #{@namespace.name}"
    )
  end

  def notify_limit(namespace, recipients, percentage_of_available_mins)
    @namespace = namespace
    @percentage_of_available_mins = percentage_of_available_mins

    mail(
      bcc: recipients,
      subject: "Action required: Less than #{percentage_of_available_mins}% " \
               "of Pipeline minutes remain for #{@namespace.name}"
    )
  end
end
