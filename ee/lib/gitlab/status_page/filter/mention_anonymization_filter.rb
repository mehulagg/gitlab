# frozen_string_literal: true

module Gitlab
  module StatusPage
    module Filter
      # HTML filter that replaces mention links with an anonymized plain version.
      #
      # This filter should be run before any references are redacted, before
      # +Banzai::Filter::ReferenceRedactorFilter+, so it's easier to find and
      # anonymize `user` references.
      class MentionAnonymizationFilter < HTML::Pipeline::Filter
        LINK_CSS_SELECTOR = "a.gfm[data-reference-type='user']"

        # Static for now. In https://gitlab.com/gitlab-org/gitlab/-/issues/209114
        # we'll map names with a more sophisticated approach.
        ANONYMIZED_NAME = 'Incident Responder'

        def call
          doc.css(LINK_CSS_SELECTOR).each do |link_node|
            link_node.replace(ANONYMIZED_NAME)
          end

          doc.to_html
        end
      end
    end
  end
end
