# frozen_string_literal: true

module Emails
  module InProductMarketing
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

      mail_to(user.notification_email_for(@group))
    end

    private

    def subject_line
      {
        create: [
          s_('InProductMarketing|Create a project in GitLab in 5 minutes'),
          s_('InProductMarketing|Import your project and code from GitHub, Bitbucket and others'),
          s_('InProductMarketing|Understand repository mirroring')
        ],
        verify: [
          s_('InProductMarketing|Feel the need for speed?'),
          s_('InProductMarketing|3 ways to dive into GitLab CI/CD'),
          s_('InProductMarketing|Explore the power of GitLab CI/CD')
        ],
        trial: [
          s_('InProductMarketing|Go farther with GitLab'),
          s_('InProductMarketing|Automated security scans directly within GitLab'),
          s_('InProductMarketing|Take your source code management to the next level')
        ],
        team: [
          s_('InProductMarketing|Working in GitLab = more efficient'),
          s_("InProductMarketing|Multiple owners, confusing workstreams? We've got you covered"),
          s_('InProductMarketing|Your teams can be more efficient')
        ]
      }[@track][@series]
    end

    def mail_to(to)
      mail(to: to, subject: subject_line, from: FROM_ADDRESS, reply_to: FROM_ADDRESS, **CUSTOM_HEADERS) do |format|
        format.html { render layout: nil }
        format.text { render layout: nil }
      end
    end
  end
end
