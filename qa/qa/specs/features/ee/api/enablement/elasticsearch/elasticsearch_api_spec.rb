# frozen_string_literal: true

require 'securerandom'

module QA
  context 'Enablement:Search' do
    include Support::Api
    describe 'When using elasticsearch API to search for a known blob', :orchestrated, :elasticsearch, :requires_admin, quarantine: { type: :new } do
      before(:all) do
        @api_client = Runtime::API::Client.new(:gitlab)
        @project_file_content = "elasticsearch: #{SecureRandom.hex(8)}"
        non_member_user = Resource::User.fabricate_or_use('non_member_user', 'non_member_user_password')
        @non_member_api_client = Runtime::API::Client.new(user: non_member_user)
        @elasticsearch_original_state_on = elasticsearch_on?(@api_client)

        unless @elasticsearch_original_state_on
          QA::EE::Resource::Settings::Elasticsearch.fabricate_via_api!
          sleep(60)
          # wait for the change to propagate before inserting records or else 
          # Gitlab::CurrentSettings.elasticsearch_indexing and 
          # Elastic::ApplicationVersionedSearch::searchable? will be false
          # this sleep can be removed after we're able to query logs via the API 
          # as per this issue https://gitlab.com/gitlab-org/quality/team-tasks/issues/395
        end

        @project = create_project("api-es-#{SecureRandom.hex(8)}", @api_client)
        push_file_to_project(@project, 'README.md', @project_file_content)
      end

      after(:all) do
        if !@elasticsearch_original_state_on && !@api_client.nil?
          disable_elasticsearch(@api_client)
        end
      end

      it 'searches public project and finds a blob as an non-member user' do
        successful_search(@non_member_api_client)
      end

      describe 'When searching a private repository' do
        before(:all) do
          set_project_visibility(@api_client, @project.id, 'private')
        end

        it 'finds a blob as an authorized user' do
          successful_search(@api_client)
        end

        it 'does not find a blob as an non-member user' do
          QA::Support::Retrier.retry_on_exception(max_attempts: 10, sleep_interval: 3) do
            get create_search_request(@non_member_api_client, 'blobs', @project_file_content).url
            expect_status(QA::Support::Api::HTTP_STATUS_OK)
            expect(json_body).to be_empty
          end
        end
      end

      private

      def successful_search(api_client)
        QA::Support::Retrier.retry_on_exception(max_attempts: 10, sleep_interval: 3) do
          get create_search_request(api_client, 'blobs', @project_file_content).url
          expect_status(QA::Support::Api::HTTP_STATUS_OK)

          raise 'Empty search result returned' if json_body.empty?

          expect(json_body[0][:data]).to match(@project_file_content)
          expect(json_body[0][:project_id]).to equal(@project.id)
        end
      end
    end
  end
end
