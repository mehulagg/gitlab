# frozen_string_literal: true

module QA
  module Resource
    module Repository
      class WikiPush < Repository::Push
        attribute :wiki do
          Wiki.fabricate! do |resource|
            resource.title = 'Home'
            resource.content = '# My First Wiki Content'
            resource.message = 'Update home'
          end
        end

        def initialize
          @file_name = 'Home.md'
          @file_content = '# Welcome to My Wiki'
          @commit_message = 'Updating Home Page'
          @branch_name = 'master'
          @new_branch = false
        end

        def repository_http_uri
          @repository_http_uri ||= wiki.repository_http_location.uri
        end

        def repository_ssh_uri
          @repository_ssh_uri ||= wiki.repository_ssh_location.uri
        end

        def fabricate!
          super
          wiki.visit!
        end
      end
    end
  end
end
