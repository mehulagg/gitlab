# frozen_string_literal: true

module QA
  RSpec.describe 'Geo', :orchestrated, :geo do
    describe 'Personal snippet' do
      let(:snippet_title) { "Geo personal snippet-#{SecureRandom.hex(8)}" }
      let(:snippet_description) { 'Geo personal snippet description' }
      let(:file_name) { 'geo_personal_snippet_file.md' }
      let(:file_content) { "### Geo personal snippet heading\n\n[GitLab link](https://gitlab.com/)" }

      it 'replicates to the Geo secondary site', testcase: 'https://gitlab.com/gitlab-org/quality/testcases/-/issues/912' do
        QA::Flow::Login.while_signed_in(address: :geo_primary) do
          Page::Main::Menu.perform do |menu|
            menu.go_to_more_dropdown_option(:snippets_link)
          end

          Resource::Snippet.fabricate_via_browser_ui! do |snippet|
            snippet.title = snippet_title
            snippet.description = snippet_description
            snippet.visibility = 'Private'
            snippet.file_name = file_name
            snippet.file_content = file_content
          end
        end

        QA::Runtime::Logger.debug('Visiting the secondary Geo site')

        QA::Flow::Login.while_signed_in(address: :geo_secondary) do
          EE::Page::Main::Banner.perform do |banner|
            expect(banner).to have_secondary_read_only_banner
          end

          Page::Main::Menu.perform do |menu|
            menu.go_to_more_dropdown_option(:snippets_link)
          end

          Page::Dashboard::Snippet::Index.perform do |index|
            index.wait_for_snippet_replication(snippet_title)
            index.click_snippet_link(snippet_title)
          end

          Page::Dashboard::Snippet::Show.perform do |snippet|
            aggregate_failures 'checking snippet details' do
              expect(snippet).to have_snippet_title(snippet_title)
              expect(snippet).to have_snippet_description(snippet_description)
              expect(snippet).to have_visibility_type(/private/i)
              expect(snippet).to have_file_name(file_name)
              expect(snippet).to have_file_content('Geo personal snippet heading')
              expect(snippet).to have_file_content('GitLab link')
              expect(snippet).to have_no_file_content('###')
              expect(snippet).to have_no_file_content('https://gitlab.com/')
            end
          end
        end
      end
    end
  end
end
