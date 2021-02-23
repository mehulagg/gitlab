# frozen_string_literal: true

module Banzai
  module Filter
    # HTML filter that replaces the Jira private images with the link to the image.
    class JiraPrivateImageLinkFilter < HTML::Pipeline::Filter
      PRIVATE_IMAGE_PATH = '/secure/attachment/'

      def call
        doc.xpath('descendant-or-self::img').each do |img|
          next unless img['src'].start_with?(PRIVATE_IMAGE_PATH)

          img_link = "#{project.jira_service.url}#{img['src']}"
          link = "<a href=\"#{img_link}\">#{img_link}</a>"

          img.replace(link)
        end

        doc
      end

      def project
        context[:project]
      end
    end
  end
end
