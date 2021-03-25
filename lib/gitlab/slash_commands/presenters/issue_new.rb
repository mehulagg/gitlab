# frozen_string_literal: true

module Gitlab
  module SlashCommands
    module Presenters
      class IssueNew < Presenters::Base
        include Presenters::IssueBase

        def present
          in_channel_response(response_message)
        end

        private

        def fallback_message
          "New issue #{issue.to_reference}: #{issue.title}"
        end

        def fields_with_markdown
          %i(pretext text)
        end

        def pretext
          "I created an issue on #{author_profile_link}'s behalf: *#{issue_link}* in #{project_link}"
        end

        def issue_link
          "[#{issue.to_reference}](#{project_issue_url(issue.project, issue)})"
        end

        def response_message(custom_pretext: pretext)
          {
            attachments: [
            {
              fallback:     fallback_message,
              pretext:      custom_pretext,
              text:         text,
              mrkdwn_in:    fields_with_markdown
            }
          ]
          }
        end
      end
    end
  end
end
