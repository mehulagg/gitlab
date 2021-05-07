# frozen_string_literal: true

require 'spec_helper'

RSpec.describe WebHookService do
  include StubRequests

  let_it_be(:project) { create(:project) }
  let_it_be(:project_hook) { create(:project_hook) }

  let(:headers) do
    {
      'Content-Type' => 'application/json',
      'User-Agent' => "GitLab/#{Gitlab::VERSION}",
      'X-Gitlab-Event' => 'Push Hook'
    }
  end

  let(:data) do
    { before: 'oldrev', after: 'newrev', ref: 'ref' }
  end

  let(:service_instance) { described_class.new(project_hook, data, :push_hooks) }

  describe '#initialize' do
    before do
      stub_application_setting(setting_name => setting)
    end

    shared_examples_for 'respects outbound network setting' do
      context 'when local requests are allowed' do
        let(:setting) { true }

        it { expect(hook.request_options[:allow_local_requests]).to be_truthy }
      end

      context 'when local requests are not allowed' do
        let(:setting) { false }

        it { expect(hook.request_options[:allow_local_requests]).to be_falsey }
      end
    end

    context 'when SystemHook' do
      let(:setting_name) { :allow_local_requests_from_system_hooks }
      let(:hook) { described_class.new(build(:system_hook), data, :system_hook) }

      include_examples 'respects outbound network setting'
    end

    context 'when ProjectHook' do
      let(:setting_name) { :allow_local_requests_from_web_hooks_and_services }
      let(:hook) { described_class.new(build(:project_hook), data, :project_hook) }

      include_examples 'respects outbound network setting'
    end
  end

  describe '#execute' do
    before do
      project.hooks << [project_hook]
    end

    context 'when token is defined' do
      let(:project_hook) { create(:project_hook, :token) }

      it 'POSTs to the webhook URL' do
        stub_full_request(project_hook.url, method: :post)

        service_instance.execute

        expect(WebMock).to have_requested(:post, stubbed_hostname(project_hook.url)).with(
          headers: headers.merge({ 'X-Gitlab-Token' => project_hook.token })
        ).once
      end
    end

    it 'POSTs the data as JSON' do
      stub_full_request(project_hook.url, method: :post)

      service_instance.execute

      expect(WebMock).to have_requested(:post, stubbed_hostname(project_hook.url)).with(
        headers: headers
      ).once
    end

    context 'when auth credentials are present' do
      let(:url) {'https://example.org'}
      let(:project_hook) { create(:project_hook, url: 'https://demo:demo@example.org/') }

      it 'uses the credentials' do
        stub_full_request(url, method: :post)

        service_instance.execute

        expect(WebMock).to have_requested(:post, stubbed_hostname(url)).with(
          headers: headers.merge('Authorization' => 'Basic ZGVtbzpkZW1v')
        ).once
      end
    end

    context 'when auth credentials are partial present' do
      let(:url) {'https://example.org'}
      let(:project_hook) { create(:project_hook, url: 'https://demo@example.org/') }

      it 'uses the credentials anyways' do
        stub_full_request(url, method: :post)

        service_instance.execute

        expect(WebMock).to have_requested(:post, stubbed_hostname(url)).with(
          headers: headers.merge('Authorization' => 'Basic ZGVtbzo=')
        ).once
      end
    end

    it 'catches exceptions' do
      stub_full_request(project_hook.url, method: :post).to_raise(StandardError.new('Some error'))

      expect { service_instance.execute }.to raise_error(StandardError)
    end

    it 'handles exceptions' do
      exceptions = [SocketError, OpenSSL::SSL::SSLError, Errno::ECONNRESET, Errno::ECONNREFUSED, Errno::EHOSTUNREACH, Net::OpenTimeout, Net::ReadTimeout, Gitlab::HTTP::BlockedUrlError, Gitlab::HTTP::RedirectionTooDeep]
      exceptions.each do |exception_class|
        exception = exception_class.new('Exception message')

        stub_full_request(project_hook.url, method: :post).to_raise(exception)
        expect(service_instance.execute).to eq({ status: :error, message: exception.to_s })
        expect { service_instance.execute }.not_to raise_error
      end
    end

    context 'when url is not encoded' do
      let(:project_hook) { create(:project_hook, url: 'http://server.com/my path/') }

      it 'handles exceptions' do
        expect(service_instance.execute).to eq(status: :error, message: 'bad URI(is not URI?): "http://server.com/my path/"')
        expect { service_instance.execute }.not_to raise_error
      end
    end

    context 'when request body size is too big' do
      it 'does not perform the request' do
        stub_const("#{described_class}::REQUEST_BODY_SIZE_LIMIT", 10.bytes)

        expect(service_instance.execute).to eq({ status: :error, message: "Gitlab::Json::LimitedEncoder::LimitExceeded" })
      end
    end

    it 'handles 200 status code' do
      stub_full_request(project_hook.url, method: :post).to_return(status: 200, body: 'Success')

      expect(service_instance.execute).to include({ status: :success, http_status: 200, message: 'Success' })
    end

    it 'handles 2xx status codes' do
      stub_full_request(project_hook.url, method: :post).to_return(status: 201, body: 'Success')

      expect(service_instance.execute).to include({ status: :success, http_status: 201, message: 'Success' })
    end

    context 'execution logging' do
      let(:hook_log) { project_hook.web_hook_logs.last }

      context 'with success' do
        before do
          stub_full_request(project_hook.url, method: :post).to_return(status: 200, body: 'Success')
          service_instance.execute
        end

        it 'log successful execution' do
          expect(hook_log.trigger).to eq('push_hooks')
          expect(hook_log.url).to eq(project_hook.url)
          expect(hook_log.request_headers).to eq(headers)
          expect(hook_log.response_body).to eq('Success')
          expect(hook_log.response_status).to eq('200')
          expect(hook_log.execution_duration).to be > 0
          expect(hook_log.internal_error_message).to be_nil
        end
      end

      context 'with exception' do
        before do
          stub_full_request(project_hook.url, method: :post).to_raise(SocketError.new('Some HTTP Post error'))
          service_instance.execute
        end

        it 'log failed execution' do
          expect(hook_log.trigger).to eq('push_hooks')
          expect(hook_log.url).to eq(project_hook.url)
          expect(hook_log.request_headers).to eq(headers)
          expect(hook_log.response_body).to eq('')
          expect(hook_log.response_status).to eq('internal error')
          expect(hook_log.execution_duration).to be > 0
          expect(hook_log.internal_error_message).to eq('Some HTTP Post error')
        end
      end

      context 'with unsafe response body' do
        before do
          stub_full_request(project_hook.url, method: :post).to_return(status: 200, body: "\xBB")
          service_instance.execute
        end

        it 'log successful execution' do
          expect(hook_log.trigger).to eq('push_hooks')
          expect(hook_log.url).to eq(project_hook.url)
          expect(hook_log.request_headers).to eq(headers)
          expect(hook_log.response_body).to eq('')
          expect(hook_log.response_status).to eq('200')
          expect(hook_log.execution_duration).to be > 0
          expect(hook_log.internal_error_message).to be_nil
        end
      end
    end
  end

  describe '#async_execute' do
    def expect_worker(hook)
      expect(WebHookWorker).to receive(:perform_async).with(hook.id, data, 'push_hooks')
    end

    def expect_rate_limiter(hook, threshold:, throttled: false)
      expect(Gitlab::ApplicationRateLimiter).to receive(:throttled?)
        .with(:web_hook_calls, scope: [hook], threshold: threshold)
        .and_return(throttled)
    end

    context 'when rate limiting is not configured' do
      it 'queues a worker without tracking the call' do
        expect(Gitlab::ApplicationRateLimiter).not_to receive(:throttled?)
        expect_worker(project_hook)

        service_instance.async_execute
      end
    end

    context 'when rate limiting is configured' do
      let_it_be(:threshold) { 3 }
      let_it_be(:plan_limits) { create(:plan_limits, :default_plan, web_hook_calls: threshold) }

      it 'queues a worker and tracks the call' do
        expect_rate_limiter(project_hook, threshold: threshold)
        expect_worker(project_hook)

        service_instance.async_execute
      end

      context 'when the hook is throttled (via mock)' do
        before do
          expect_rate_limiter(project_hook, threshold: threshold, throttled: true)
        end

        it 'does not queue a worker and logs an error' do
          expect(WebHookWorker).not_to receive(:perform_async)

          expect(Gitlab::AuthLogger).to receive(:error).with(
            message: 'Webhook rate limit exceeded',
            hook_id: project_hook.id,
            hook_name: 'push_hooks'
          )

          expect(Gitlab::AppLogger).to receive(:error).with(
            message: 'Webhook rate limit exceeded',
            class: 'WebHookService',
            hook_id: project_hook.id,
            hook_name: 'push_hooks'
          )

          service_instance.async_execute
        end
      end

      context 'when the hook is throttled (via Redis)', :clean_gitlab_redis_cache do
        before do
          # Set a high interval to avoid intermittent failures in CI
          allow(Gitlab::ApplicationRateLimiter).to receive(:rate_limits).and_return(
            web_hook_calls: { interval: 1.day }
          )

          expect_worker(project_hook).exactly(threshold).times

          threshold.times { service_instance.async_execute }
        end

        it 'stops queueing workers and logs errors' do
          expect(Gitlab::AuthLogger).to receive(:error).twice
          expect(Gitlab::AppLogger).to receive(:error).twice

          2.times { service_instance.async_execute }
        end

        it 'still queues workers for other hooks' do
          other_hook = create(:project_hook)

          expect_worker(other_hook)

          described_class.new(other_hook, data, :push_hooks).async_execute
        end
      end

      context 'when the feature flag is disabled' do
        before do
          stub_feature_flags(web_hooks_rate_limit: false)
        end

        it 'queues a worker without tracking the call' do
          expect(Gitlab::ApplicationRateLimiter).not_to receive(:throttled?)
          expect_worker(project_hook)

          service_instance.async_execute
        end
      end
    end
  end
end
