# frozen_string_literal: true

module QA
  RSpec.describe 'Plan', :orchestrated, :service_desk do
    describe 'Service desk' do
      include Support::Api
      let(:template_name) { 'custom_service_desk_template' }
      let(:template_content) { 'This is a custom service desk template test' }
      let(:new_note_template_content) { 'This is a custom service desk new note template test' }
      let(:thank_you_template_content) { 'This is a custom service desk thank you template test' }
      # let(:service_desk_email) { mailhog_email }

      let(:user) do
        Resource::User.fabricate_or_use(Runtime::Env.gitlab_qa_username_1, Runtime::Env.gitlab_qa_password_1)
      end

      let(:project) do
        Resource::Project.fabricate_via_api! do |project|
          project.name = 'service-desk-template-test'
          project.initialize_with_readme = true
        end
      end

      before do
        Flow::Login.sign_in

        Resource::Repository::Commit.fabricate_via_api! do |commit|
          commit.project = project
          commit.commit_message = 'Add custom service desk templates'
          commit.add_files([
            {
              file_path: ".gitlab/issue_templates/#{template_name}.md",
              content: template_content
            },
            {
              file_path: ".gitlab/service_desk_templates/new_note.md",
              content: new_note_template_content
            },
            {
              file_path: ".gitlab/service_desk_templates/thank_you.md",
              content: thank_you_template_content
            }
          ])
        end
      end

      it 'uses custom templates for email notifications', testcase: 'https://gitlab.com/gitlab-org/quality/testcases/-/issues/1235' do
        project.visit!

        Page::Project::Menu.perform(&:go_to_general_settings)
        Page::Project::Settings::Main.perform(&:expand_service_desk_settings)
        Page::Project::Settings::ServiceDesk.perform do |sd_settings|
          sd_settings.select_service_desk_email_template(template_name)
        end
      end

      private

      def mailhog_json
        Support::Retrier.retry_until(sleep_interval: 1) do
          Runtime::Logger.debug(%Q[retrieving "#{QA::Runtime::MailHog.api_messages_url}"])

          mailhog_response = get QA::Runtime::MailHog.api_messages_url

          mailhog_data = JSON.parse(mailhog_response.body)
          total = mailhog_data.dig('total')
          subjects = mailhog_data.dig('items')
            .map(&method(:mailhog_item_subject))
            .join("\n")

          Runtime::Logger.debug(%Q[Total number of emails: #{total}])
          Runtime::Logger.debug(%Q[Subjects:\n#{subjects}])

          # Expect at least two invitation messages: group and project
          mailhog_data if total >= 2
        end
      end

      def mailhog_item_subject(item)
        item.dig('Content', 'Headers', 'Subject', 0)
      end
    end
  end
end
