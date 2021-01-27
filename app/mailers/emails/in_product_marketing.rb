# frozen_string_literal: true

module Emails
  module InProductMarketing
    include InProductMarketingHelper

    FROM_ADDRESS = 'GitLab <team@gitlab.com>'.freeze
    CUSTOM_HEADERS = {
      'X-Mailgun-Track' => 'yes',
      'X-Mailgun-Track-Clicks' => 'yes',
      'X-Mailgun-Track-Opens' => 'yes',
      'X-Mailgun-Tag' => 'marketing'
    }.freeze

    def in_product_marketing_email(recipient_id, group_id, track, series)
      @track = track
      @series = series

      user = User.find(recipient_id)
      @group = Group.find(group_id)

      email = user.notification_email_for(@group)
      subject = subject_line(track, series)

      mail_to(to: email, subject: subject)
    end

    private

    def mail_to(to:, subject:)
      mail(to: to, subject: subject, from: FROM_ADDRESS, reply_to: FROM_ADDRESS, **CUSTOM_HEADERS) do |format|
        format.html { render layout: nil }
        format.text { render layout: nil }
      end
    end
  end
end
