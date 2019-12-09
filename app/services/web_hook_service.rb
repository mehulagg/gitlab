# frozen_string_literal: true

class WebHookService
  attr_accessor :hook, :data, :hook_name, :request_options

  def initialize(hook, data, hook_name)
    @hook = hook
    @data = data
    @hook_name = hook_name.to_s
    @request_options = {
      timeout: Gitlab.config.gitlab.webhook_timeout,
      allow_local_requests: hook.allow_local_requests?
    }
  end

  def execute
    start_time = Gitlab::Metrics::System.monotonic_time

    response = if parsed_url.userinfo.blank?
                 make_request(hook.url)
               else
                 make_request_with_auth
               end

    hook.log_execution(
      trigger: hook_name,
      headers: build_headers(hook_name),
      request_data: data,
      response_headers: format_response_headers(response),
      response_body: response.body,
      response_status: response.code,
      execution_duration: Gitlab::Metrics::System.monotonic_time - start_time
    )

    {
      status: :success,
      http_status: response.code,
      message: response.to_s
    }
  rescue SocketError, OpenSSL::SSL::SSLError, Errno::ECONNRESET, Errno::ECONNREFUSED, Errno::EHOSTUNREACH, Net::OpenTimeout, Net::ReadTimeout, Gitlab::HTTP::BlockedUrlError, Gitlab::HTTP::RedirectionTooDeep => e
    hook.log_execution(
      trigger: hook_name,
      headers: build_headers(hook_name),
      request_data: data,
      response_status: 'internal error',
      execution_duration: Gitlab::Metrics::System.monotonic_time - start_time,
      error_message: e.to_s
    )

    Rails.logger.error("WebHook Error => #{e}") # rubocop:disable Gitlab/RailsLogger

    {
      status: :error,
      message: e.to_s
    }
  end

  def async_execute
    WebHookWorker.perform_async(hook.id, data, hook_name)
  end

  private

  def parsed_url
    @parsed_url ||= URI.parse(hook.url)
  end

  def make_request(url, basic_auth = false)
    Gitlab::HTTP.post(url,
      body: data.to_json,
      headers: build_headers(hook_name),
      verify: hook.enable_ssl_verification,
      basic_auth: basic_auth,
      **request_options)
  end

  def make_request_with_auth
    post_url = hook.url.gsub("#{parsed_url.userinfo}@", '')
    basic_auth = {
      username: CGI.unescape(parsed_url.user),
      password: CGI.unescape(parsed_url.password.presence || '')
    }
    make_request(post_url, basic_auth)
  end

  def build_headers(hook_name)
    @headers ||= begin
      {
        'Content-Type' => 'application/json',
        'X-Gitlab-Event' => hook_name.singularize.titleize
      }.tap do |hash|
        hash['X-Gitlab-Token'] = Gitlab::Utils.remove_line_breaks(hook.token) if hook.token.present?
      end
    end
  end

  # Make response headers more stylish
  # Net::HTTPHeader has downcased hash with arrays: { 'content-type' => ['text/html; charset=utf-8'] }
  # This method format response to capitalized hash with strings: { 'Content-Type' => 'text/html; charset=utf-8' }
  def format_response_headers(response)
    response.headers.each_capitalized.to_h
  end
end
