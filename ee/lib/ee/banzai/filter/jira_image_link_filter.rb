# frozen_string_literal: true

module EE
  module Banzai
    module Filter
      class JiraImageLinkFilter < HTML::Pipeline::Filter
        def call
          doc.xpath('descendant-or-self::img').each do |img|
            if img['src'].start_with?('/secure/attachment/')
              img['src'] = 'https://gitlab.com/gitlab-org/gitlab/-/design_management/designs/154651/cf2a6f1408407eb932657ea598f3b10a4e4c1cb6/resized_image/v432x230'
            end
          end

          doc
        end
      end
    end
  end
end
