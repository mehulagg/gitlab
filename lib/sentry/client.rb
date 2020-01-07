# frozen_string_literal: true

module Sentry
  class Client
    include Sentry::Client::Event
    include Sentry::Client::Projects
    include Sentry::Client::Issue

    Error = Class.new(StandardError)
    MissingKeysError = Class.new(StandardError)
    ResponseInvalidSizeError = Class.new(StandardError)
    BadRequestError = Class.new(StandardError)

    SENTRY_API_SORT_VALUE_MAP = {
      # <accepted_by_client> => <accepted_by_sentry_api>
      'frequency' => 'freq',
      'first_seen' => 'new',
      'last_seen' => nil
    }.freeze

    attr_accessor :url, :token

    def initialize(api_url, token)
      @url = api_url
      @token = token
    end

    def list_issues(**keyword_args)
      response = get_issues(keyword_args)

      issues = response[:issues]
      pagination = response[:pagination]

      validate_size(issues)

      handle_mapping_exceptions do
        {
          issues: map_to_errors(issues),
          pagination: pagination
        }
      end
    end

    private

    def validate_size(issues)
      return if Gitlab::Utils::DeepSize.new(issues).valid?

      raise ResponseInvalidSizeError, "Sentry API response is too big. Limit is #{Gitlab::Utils::DeepSize.human_default_max_size}."
    end

    def handle_mapping_exceptions(&block)
      yield
    rescue KeyError => e
      Gitlab::ErrorTracking.track_exception(e)
      raise MissingKeysError, "Sentry API response is missing keys. #{e.message}"
    end

    def request_params
      {
        headers: {
          'Authorization' => "Bearer #{@token}"
        },
        follow_redirects: false
      }
    end

    def http_get(url, params = {})
      http_request do
        Gitlab::HTTP.get(url, **request_params.merge(params))
      end
    end

    def http_put(url, params = {})
      http_request do
        Gitlab::HTTP.put(url, **request_params.merge({ body: params }))
      end
    end

    def http_request
      response = handle_request_exceptions do
        yield
      end

      handle_response(response)
    end

    def get_issues(**keyword_args)
      response = http_get(
        issues_api_url,
        query: list_issue_sentry_query(keyword_args)
      )

      {
        issues: response[:body],
        pagination: Sentry::PaginationParser.parse(response[:headers])
      }
    end

    def list_issue_sentry_query(issue_status:, limit:, sort: nil, search_term: '', cursor: nil)
      unless SENTRY_API_SORT_VALUE_MAP.key?(sort)
        raise BadRequestError, 'Invalid value for sort param'
      end

      {
        query: "is:#{issue_status} #{search_term}".strip,
        limit: limit,
        sort: SENTRY_API_SORT_VALUE_MAP[sort],
        cursor: cursor
      }.compact
    end

    def handle_request_exceptions
      yield
    rescue Gitlab::HTTP::Error => e
      Gitlab::ErrorTracking.track_exception(e)
      raise_error 'Error when connecting to Sentry'
    rescue Net::OpenTimeout
      raise_error 'Connection to Sentry timed out'
    rescue SocketError
      raise_error 'Received SocketError when trying to connect to Sentry'
    rescue OpenSSL::SSL::SSLError
      raise_error 'Sentry returned invalid SSL data'
    rescue Errno::ECONNREFUSED
      raise_error 'Connection refused'
    rescue => e
      Gitlab::ErrorTracking.track_exception(e)
      raise_error "Sentry request failed due to #{e.class}"
    end

    def handle_response(response)
      unless response.code == 200
        raise_error "Sentry response status code: #{response.code}"
      end

      { body: response.parsed_response, headers: response.headers }
    end

    def raise_error(message)
      raise Client::Error, message
    end

    def issues_api_url
      issues_url = URI(@url + '/issues/')
      issues_url.path.squeeze!('/')

      issues_url
    end

    def map_to_errors(issues)
      issues.map(&method(:map_to_error))
    end

    def issue_url(id)
      issues_url = @url + "/issues/#{id}"

      parse_sentry_url(issues_url)
    end

    def project_url
      parse_sentry_url(@url)
    end

    def parse_sentry_url(api_url)
      url = ErrorTracking::ProjectErrorTrackingSetting.extract_sentry_external_url(api_url)

      uri = URI(url)
      uri.path.squeeze!('/')
      # Remove trailing slash
      uri = uri.to_s.gsub(/\/\z/, '')

      uri
    end

    def map_to_error(issue)
      Gitlab::ErrorTracking::Error.new(
        id: issue.fetch('id'),
        first_seen: issue.fetch('firstSeen', nil),
        last_seen: issue.fetch('lastSeen', nil),
        title: issue.fetch('title', nil),
        type: issue.fetch('type', nil),
        user_count: issue.fetch('userCount', nil),
        count: issue.fetch('count', nil),
        message: issue.dig('metadata', 'value'),
        culprit: issue.fetch('culprit', nil),
        external_url: issue_url(issue.fetch('id')),
        short_id: issue.fetch('shortId', nil),
        status: issue.fetch('status', nil),
        frequency: issue.dig('stats', '24h'),
        project_id: issue.dig('project', 'id'),
        project_name: issue.dig('project', 'name'),
        project_slug: issue.dig('project', 'slug')
      )
    end
  end
end
