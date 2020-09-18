# frozen_string_literal: true

require 'airborne'
require 'securerandom'

module QA
  RSpec.describe 'Enablement:Search' do
    describe 'When using elasticsearch API to search for a known blob', :orchestrated, :elasticsearch, :requires_admin, only: { subdomain: :nightly } do
      p1_threshold = 15
      p2_threshold = 10
      p3_threshold = 3
      let(:project_file_content) { "elasticsearch: #{SecureRandom.hex(8)}" }
      let(:api_client) { Runtime::API::Client.new(:gitlab) }

      let(:project) do
        Resource::Project.fabricate_via_api! do |project|
          project.name = "api-es-#{SecureRandom.hex(8)}"
        end
      end

      let(:elasticsearch_original_state_on?) { Runtime::Search.elasticsearch_on?(api_client) }

      before do
        unless elasticsearch_original_state_on?
          QA::EE::Resource::Settings::Elasticsearch.fabricate_via_api!
        end

        Resource::Repository::Commit.fabricate_via_api! do |commit|
          commit.project = project
          commit.add_files([
            { file_path: 'README.md', content: project_file_content }
          ])
        end
      end

      after do
        if !elasticsearch_original_state_on? && !api_client.nil?
          Runtime::Search.disable_elasticsearch(api_client)
        end
      end

      it 'searches public project and finds a blob as an non-member user' do
        start_time = Time.now
        while (Time.now - start_time) / 60 < p1_threshold
          get Runtime::Search.create_search_request(api_client, 'blobs', project_file_content).url
          expect_status(QA::Support::Api::HTTP_STATUS_OK)

          if json_body[0][:data].match(project_file_content) && json_body[0][:project_id].equal(project.id)
            break
          end

          sleep 10
        end

        if (Time.now - start_time) / 60 >= p1_threshold
          raise "Search failed during P1 threshold time of #{p1_threshold} minutes. Recommend filing P1 bug."
        elsif (Time.now - start_time) / 60 >= p2_threshold
          raise "Search succeeded, but only after P2 threshold time of #{p2_threshold} minutes. Recommend filing P2 bug."
        elsif (Time.now - start_time) / 60 >= p3_threshold
          raise "Search succeeded, but only after P3 threshold time of #{p3_threshold} minutes. Recommend filing P3 bug."
        else
          puts "Search sucessfully completed before #{p3_threshold} minutes."
        end
      end
    end
  end
end
