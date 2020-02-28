# frozen_string_literal: true

module QA
  module Support
    module Api
      HTTP_STATUS_OK = 200
      HTTP_STATUS_CREATED = 201
      HTTP_STATUS_NO_CONTENT = 204
      HTTP_STATUS_ACCEPTED = 202

      def post(url, payload)
        RestClient::Request.execute(
          method: :post,
          url: url,
          payload: payload,
          verify_ssl: false)
      rescue RestClient::ExceptionWithResponse => e
        return_response_or_raise(e)
      end

      def get(url, raw_response: false)
        RestClient::Request.execute(
          method: :get,
          url: url,
          verify_ssl: false,
          raw_response: raw_response)
      rescue RestClient::ExceptionWithResponse => e
        return_response_or_raise(e)
      end

      def put(url, payload)
        RestClient::Request.execute(
          method: :put,
          url: url,
          payload: payload,
          verify_ssl: false)
      rescue RestClient::ExceptionWithResponse => e
        return_response_or_raise(e)
      end

      def delete(url)
        RestClient::Request.execute(
          method: :delete,
          url: url,
          verify_ssl: false)
      rescue RestClient::ExceptionWithResponse => e
        return_response_or_raise(e)
      end

      def head(url)
        RestClient::Request.execute(
          method: :head,
          url: url,
          verify_ssl: false)
      rescue RestClient::ExceptionWithResponse => e
        return_response_or_raise(e)
      end

      def parse_body(response)
        JSON.parse(response.body, symbolize_names: true)
      end

      def return_response_or_raise(error)
        raise error unless error.respond_to?(:response) && error.response

        error.response
      end

      def create_project(project_name, api_client, project_description = 'default')
        project = Resource::Project.fabricate_via_api! do |project|
          project.add_name_uuid = false
          project.name = project_name
          project.description = project_description
          project.api_client = api_client
          project.visibility = 'public'
        end
        project
      end

      def push_file_to_project(target_project, file_name, file_content)
        Resource::Repository::ProjectPush.fabricate! do |push|
          push.project = target_project
          push.file_name = file_name
          push.file_content = file_content
        end
      end

      def set_project_visibility(api_client, project_id, visibility)
        request = Runtime::API::Request.new(api_client, "/projects/#{project_id}")
        put request.url, visibility: visibility
        expect_status(HTTP_STATUS_OK)
      end

      def create_search_request(api_client, scope, search_term)
        Runtime::API::Request.new(api_client, '/search', scope: scope, search: search_term)
      end

      def elasticsearch_on?(api_client)
        elasticsearch_state_request = Runtime::API::Request.new(api_client, '/application/settings')
        response = get elasticsearch_state_request.url

        if response.to_s.match(/"elasticsearch_search":true/) && response.to_s.match(/"elasticsearch_indexing":true/)
          return true
        else
          return false
        end
      end

      def disable_elasticsearch(api_client)
        disable_elasticsearch_request = Runtime::API::Request.new(api_client, '/application/settings')
        put disable_elasticsearch_request.url, elasticsearch_search: false, elasticsearch_indexing: false
      end
    end
  end
end
