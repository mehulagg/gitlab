# frozen_string_literal: true
require_relative '../../qa'

# This script creates group hierarcy for testing:
# https://gitlab.com/gitlab-org/quality/testcases/-/issues/1724#note_522689094
# Required environment variables: GITLAB_QA_ACCESS_TOKEN and GITLAB_ADDRESS
# Optional environment variable: TOP_LEVEL_GROUP_NAME (defaults to 'gitlab-qa-sandbox-group')
# Run `rake create_groups_hierarchy` from the `qa` directory

module QA
  module Tools
    class CreateGroupsHierarchy
      include Support::Api

      def initialize
        raise ArgumentError, "Please provide GITLAB_ADDRESS" unless ENV['GITLAB_ADDRESS']
        raise ArgumentError, "Please provide GITLAB_QA_ACCESS_TOKEN" unless ENV['GITLAB_QA_ACCESS_TOKEN']

        @api_client = Runtime::API::Client.new(ENV['GITLAB_ADDRESS'], personal_access_token: ENV['GITLAB_QA_ACCESS_TOKEN'])
        @gitlab_issue_id = 323312
        @random_hex = SecureRandom.hex(4)
      end

      def run
        STDOUT.puts 'Running...'
        (1..4).each do |testcase|
          puts "Creating hierarchy for testcase #{testcase}"

          # Create A
          a_id = create_group("#{@gitlab_issue_id}-#{@random_hex}-case-#{testcase}-A")

          # Create B
          b_id = create_group("#{@gitlab_issue_id}-#{@random_hex}-case-#{testcase}-B", a_id)

          # Create C
          c_id = create_group("#{@gitlab_issue_id}-#{@random_hex}-case-#{testcase}-C", b_id)

          # Create D
          d_id = create_group("#{@gitlab_issue_id}-#{@random_hex}-case-#{testcase}-D", b_id)

          # Create E
          create_group("#{@gitlab_issue_id}-#{@random_hex}-case-#{testcase}-E", c_id)

          # Create F
          create_group("#{@gitlab_issue_id}-#{@random_hex}-case-#{testcase}-F", c_id)

          # Create G
          create_group("#{@gitlab_issue_id}-#{@random_hex}-case-#{testcase}-G", d_id)

          # Create H
          create_group("#{@gitlab_issue_id}-#{@random_hex}-case-#{testcase}-H", d_id)
        end

        STDOUT.puts "\nDone"
      end

      private

      def create_a_group_api_req(group_name, parent_id)
        params = "name=#{group_name}&path=#{group_name}&visibility=public"
        params += "&parent_id=#{parent_id}" if parent_id
        call_api(expected_response_code: 201) do
          post Runtime::API::Request.new(@api_client, "/groups").url, params
        end
      end

      def create_group(group_name, parent_id = nil)
        response = create_a_group_api_req(group_name, parent_id)
        group = JSON.parse(response.body)
        STDOUT.puts "Created a group: #{group["web_url"]}"
        group["id"]
      end

      def call_api(expected_response_code: 200)
        response = yield
        raise "API call failed with response code: #{response.code} and body: #{response.body}" unless response.code == expected_response_code

        response
      end
    end
  end
end
