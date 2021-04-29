# frozen_string_literal: true

module Gitlab
  module Email
    module Message
      module InProductMarketing
        class Base
          include Gitlab::Email::Message::InProductMarketing::Helper
          include Gitlab::Routing

          def initialize(group:, series:, format: :html)
            @group = group
            @series = series
            @format = format
          end

          attr_accessor :format

          def track
            self.class.name.demodulize.downcase.to_sym
          end

          def subject_line
            raise NotImplementedError
          end

          def tagline
            raise NotImplementedError
          end

          def title
            raise NotImplementedError
          end

          def subtitle
            raise NotImplementedError
          end

          def body_line1
            raise NotImplementedError
          end

          def body_line2
            raise NotImplementedError
          end

          def cta_text
            raise NotImplementedError
          end

          def cta_link
            case format
            when :html
              link_to cta_text, group_email_campaigns_url(group, track: track, series: series), target: '_blank', rel: 'noopener noreferrer'
            else
              [cta_text, group_email_campaigns_url(group, track: track, series: series)].join(' >> ')
            end
          end

          def unsubscribe
            parts = Gitlab.com? ? unsubscribe_com(format) : unsubscribe_self_managed(track, series, format)

            case format
            when :html
              parts.join(' ')
            else
              parts.join("\n" + ' ' * 16)
            end
          end

          def progress
            if Gitlab.com?
              s_('InProductMarketing|This is email %{series} of 3 in the %{track} series.') % { series: series + 1, track: track.to_s.humanize }
            else
              s_('InProductMarketing|This is email %{series} of 3 in the %{track} series. To disable notification emails sent by your local GitLab instance, either contact your administrator or %{unsubscribe_link}.') % { series: series + 1, track: track.to_s.humanize, unsubscribe_link: unsubscribe_link(format) }
            end
          end

          def logo_path
            ["mailers/in_product_marketing", "#{track}-#{series}.png"].join('/')
          end

          protected

          attr_reader :group, :series

          private

          def unsubscribe_com(format)
            [
              s_('InProductMarketing|If you no longer wish to receive marketing emails from us,'),
              s_('InProductMarketing|you may %{unsubscribe_link} at any time.') % { unsubscribe_link: unsubscribe_link(format) }
            ]
          end

          def unsubscribe_self_managed(track, series, format)
            [
              s_('InProductMarketing|To opt out of these onboarding emails, %{unsubscribe_link}.') % { unsubscribe_link: unsubscribe_link(format) },
              s_("InProductMarketing|If you don't want to receive marketing emails directly from GitLab, %{marketing_preference_link}.") % { marketing_preference_link: marketing_preference_link(track, series, format) }
            ]
          end

          def unsubscribe_link(format)
            unsubscribe_url = Gitlab.com? ? '%tag_unsubscribe_url%' : profile_notifications_url

            link(s_('InProductMarketing|unsubscribe'), unsubscribe_url, format)
          end

          def marketing_preference_link(track, series, format)
            params = {
              utm_source: 'SM',
              utm_medium: 'email',
              utm_campaign: 'onboarding',
              utm_term: "#{track}_#{series}"
            }

            preference_link = "https://about.gitlab.com/company/preference-center/?#{params.to_query}"

            link(s_('InProductMarketing|update your preferences'), preference_link, format)
          end
        end
      end
    end
  end
end
