# frozen_string_literal: true

require 'securerandom'

module QA
  module Resource
    module Wiki
      class GroupPage < Base
        attribute :title
        attribute :content
        attribute :slug

        attribute :group do
          Group.fabricate_via_api! do |group|
            group.path = "group-with-wiki-#{SecureRandom.hex(8)}"
          end
        end

        attribute :repository_http_location do
          EE::Page::Group::Wiki::Show.perform do |show|
            show.click_clone_repository
            show.choose_repository_clone_http
            show.repository_location
          end
        end

        def initialize
          @title = 'Home'
          @content = 'This wiki page is created via API'
        end

        def resource_web_url(resource)
          super
        rescue ResourceURLMissingError
          "#{group.web_url}/-/wikis/#{slug}"
        end

        def api_get_path
          "/groups/#{group.id}/wikis/#{slug}"
        end

        def api_post_path
          "/groups/#{group.id}/wikis"
        end

        def api_post_body
          {
            id: group.id,
            content: content,
            title: title
          }
        end

        def api_list_wiki_pages_path
          "/groups/#{group.id}/wikis"
        end

        def has_page?(page_title)
          response = get Runtime::API::Request.new(api_client, api_list_wiki_pages_path).url

          raise ResourceNotFoundError, "Request returned (#{response.code}): `#{response}`." if response.code == HTTP_STATUS_NOT_FOUND

          parse_body(response).any? { |page| page[:title] == page_title }
        end
      end
    end
  end
end
