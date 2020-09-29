# frozen_string_literal: true

module QA
  module Resource
    class Design < Base
      attr_reader :id
      attr_accessor :filename
      attr_writer :update

      attribute :issue do
        Issue.fabricate_via_api!
      end

      def initialize
        @update = false
        @filename = 'banana_sample.gif'
      end

      # TODO This will be replaced as soon as file uploads over GraphQL are implemented
      def fabricate!
        issue.visit!

        Page::Project::Issue::Show.perform do |issue|
          issue.add_design(filepath)
        end
      end

      private

      def filepath
        relative_path = if @update
          ::File.join('spec', 'fixtures', 'update', @filename)
        else
          ::File.join('spec', 'fixtures', @filename)
        end

        ::File.absolute_path(relative_path)
      end
    end
  end
end
