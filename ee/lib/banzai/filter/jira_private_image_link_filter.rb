# frozen_string_literal: true

module Banzai
  module Filter
    # HTML filter that replaces the Jira private images with the link to the image.
    class JiraPrivateImageLinkFilter < HTML::Pipeline::Filter
      PRIVATE_IMAGE_PATH = '/secure/attachment/'
      CSS_WITH_ATTACHMENT_ICON = 'with-attachment-icon'

      CSS   = 'img'
      XPATH = Gitlab::Utils::Nokogiri.css_to_xpath(CSS).freeze

      def call
        doc.xpath(XPATH).each do |img|
          next unless img['src'].start_with?(PRIVATE_IMAGE_PATH)

          img_link = project.jira_integration.web_url(img['src'])
          link = "<a class=\"#{CSS_WITH_ATTACHMENT_ICON}\" href=\"#{img_link}\">#{img_link}</a>"

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
