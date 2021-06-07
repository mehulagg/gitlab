# frozen_string_literal: true

module QA
  module Resource
    class ImportProject < Resource::Project
      attr_writer :file_path

      def initialize
        @name = "ImportedProject-#{SecureRandom.hex(8)}"
        @file = ::File.join('qa', 'fixtures', 'export.tar.gz')
      end

      def fabricate!
        self.import = true
        super

        group.visit!

        Page::Group::Show.perform(&:go_to_new_project)
        Page::Project::New.perform(&:click_import_project)

        Page::Project::Import::Selection.perform(&:click_gitlab)
        Page::Project::Import::Gitlab.perform do |import_page|
          import_page.enter_name(@name)
          import_page.attach_file(@file)
          import_page.click_import
        end
      end
    end
  end
end
