# frozen_string_literal: true

module QA
  module Resource
    class Snippet < Base
      attr_accessor :title, :description, :file_content, :visibility, :file_name, :add_file

      def initialize
        @title = 'New snippet title'
        @description = 'The snippet description'
        @visibility = 'Public'
        @file_content = 'The snippet content'
        @file_name = 'New snippet file name'
        @add_file = 0
      end

      def fabricate!
        Page::Dashboard::Snippet::Index.perform(&:go_to_new_snippet_page)

        Page::Dashboard::Snippet::New.perform do |new_page|
          new_page.fill_title(@title)
          new_page.fill_description(@description)
          new_page.set_visibility(@visibility)
          new_page.fill_file_name(@file_name)
          new_page.fill_file_content(@file_content)
          file_number = 1
          while @add_file > 0
            file_number += 1
            new_page.click_add_file
            new_page.fill_file_name(file_number.to_s + ' file name', file_number)
            new_page.fill_file_content(file_number.to_s + ' file content', file_number)
            @add_file -= 1
          end
          new_page.click_create_snippet_button
        end
      end
    end
  end
end
