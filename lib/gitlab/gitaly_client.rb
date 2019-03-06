# frozen_string_literal: true

require 'base64'

require 'gitaly'
require 'grpc/health/v1/health_pb'
require 'grpc/health/v1/health_services_pb'

module Gitlab
  module GitalyClient
    include Gitlab::Metrics::Methods

    class TooManyInvocationsError < StandardError
      attr_reader :call_site, :invocation_count, :max_call_stack

      def initialize(call_site, invocation_count, max_call_stack, most_invoked_stack)
        @call_site = call_site
        @invocation_count = invocation_count
        @max_call_stack = max_call_stack
        stacks = most_invoked_stack.join('\n') if most_invoked_stack

        msg = "GitalyClient##{call_site} called #{invocation_count} times from single request. Potential n+1?"
        msg = "#{msg}\nThe following call site called into Gitaly #{max_call_stack} times:\n#{stacks}\n" if stacks

        super(msg)
      end
    end

    PEM_REGEX = /\-+BEGIN CERTIFICATE\-+.+?\-+END CERTIFICATE\-+/m
    SERVER_VERSION_FILE = 'GITALY_SERVER_VERSION'
    MAXIMUM_GITALY_CALLS = 30
    CLIENT_NAME = (Sidekiq.server? ? 'gitlab-sidekiq' : 'gitlab-web').freeze

    MUTEX = Mutex.new

    class << self
      attr_accessor :query_time
    end

    self.query_time = 0

    define_histogram :gitaly_controller_action_duration_seconds do
      docstring "Gitaly endpoint histogram by controller and action combination"
      base_labels Gitlab::Metrics::Transaction::BASE_LABELS.merge(gitaly_service: nil, rpc: nil)
    end

    def self.stub(name, storage)
      MUTEX.synchronize do
        @stubs ||= {}
        @stubs[storage] ||= {}
        @stubs[storage][name] ||= begin
          klass = stub_class(name)
          addr = stub_address(storage)
          creds = stub_creds(storage)
          klass.new(addr, creds, interceptors: interceptors)
        end
      end
    end

    def self.interceptors
      return [] unless Gitlab::Tracing.enabled?

      [Gitlab::Tracing::GRPCInterceptor.instance]
    end
    private_class_method :interceptors

    def self.stub_cert_paths
      cert_paths = Dir["#{OpenSSL::X509::DEFAULT_CERT_DIR}/*"]
      cert_paths << OpenSSL::X509::DEFAULT_CERT_FILE if File.exist? OpenSSL::X509::DEFAULT_CERT_FILE
      cert_paths
    end

    def self.stub_certs
      return @certs if @certs

      @certs = stub_cert_paths.flat_map do |cert_file|
        File.read(cert_file).scan(PEM_REGEX).map do |cert|
          begin
            OpenSSL::X509::Certificate.new(cert).to_pem
          rescue OpenSSL::OpenSSLError => e
            Rails.logger.error "Could not load certificate #{cert_file} #{e}"
            Gitlab::Sentry.track_exception(e, extra: { cert_file: cert_file })
            nil
          end
        end.compact
      end.uniq.join("\n")
    end

    def self.stub_creds(storage)
      if URI(address(storage)).scheme == 'tls'
        GRPC::Core::ChannelCredentials.new stub_certs
      else
        :this_channel_is_insecure
      end
    end

    def self.stub_class(name)
      if name == :health_check
        Grpc::Health::V1::Health::Stub
      else
        Gitaly.const_get(name.to_s.camelcase.to_sym).const_get(:Stub)
      end
    end

    def self.stub_address(storage)
      address(storage).sub(%r{^tcp://|^tls://}, '')
    end

    def self.clear_stubs!
      MUTEX.synchronize do
        @stubs = nil
      end
    end

    def self.random_storage
      Gitlab.config.repositories.storages.keys.sample
    end

    def self.address(storage)
      params = Gitlab.config.repositories.storages[storage]
      raise "storage not found: #{storage.inspect}" if params.nil?

      address = params['gitaly_address']
      unless address.present?
        raise "storage #{storage.inspect} is missing a gitaly_address"
      end

      unless URI(address).scheme.in?(%w(tcp unix tls))
        raise "Unsupported Gitaly address: #{address.inspect} does not use URL scheme 'tcp' or 'unix' or 'tls'"
      end

      address
    end

    def self.address_metadata(storage)
      Base64.strict_encode64(JSON.dump(storage => connection_data(storage)))
    end

    def self.connection_data(storage)
      { 'address' => address(storage), 'token' => token(storage) }
    end

    # All Gitaly RPC call sites should use GitalyClient.call. This method
    # makes sure that per-request authentication headers are set.
    #
    # This method optionally takes a block which receives the keyword
    # arguments hash 'kwargs' that will be passed to gRPC. This allows the
    # caller to modify or augment the keyword arguments. The block must
    # return a hash.
    #
    # For example:
    #
    # GitalyClient.call(storage, service, rpc, request) do |kwargs|
    #   kwargs.merge(deadline: Time.now + 10)
    # end
    #
    def self.call(storage, service, rpc, request, remote_storage: nil, timeout: nil)
      start = Gitlab::Metrics::System.monotonic_time
      request_hash = request.is_a?(Google::Protobuf::MessageExts) ? request.to_h : {}

      enforce_gitaly_request_limits(:call)

      kwargs = request_kwargs(storage, timeout, remote_storage: remote_storage)
      kwargs = yield(kwargs) if block_given?

      stub(service, storage).__send__(rpc, request, kwargs) # rubocop:disable GitlabSecurity/PublicSend
    ensure
      duration = Gitlab::Metrics::System.monotonic_time - start

      # Keep track, separately, for the performance bar
      self.query_time += duration
      gitaly_controller_action_duration_seconds.observe(
        current_transaction_labels.merge(gitaly_service: service.to_s, rpc: rpc.to_s),
        duration)

      add_call_details(feature: "#{service}##{rpc}", duration: duration, request: request_hash, rpc: rpc)
    end

    def self.current_transaction_labels
      Gitlab::Metrics::Transaction.current&.labels || {}
    end
    private_class_method :current_transaction_labels

    # For some time related tasks we can't rely on `Time.now` since it will be
    # affected by Timecop in some tests, and the clock of some gitaly-related
    # components (grpc's c-core and gitaly server) use system time instead of
    # timecop's time, so tests will fail.
    # `Time.at(Process.clock_gettime(Process::CLOCK_REALTIME))` will circumvent
    # timecop.
    def self.real_time
      Time.at(Process.clock_gettime(Process::CLOCK_REALTIME))
    end
    private_class_method :real_time

    def self.authorization_token(storage)
      token = token(storage).to_s
      issued_at = real_time.to_i.to_s
      hmac = OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA256.new, token, issued_at)

      "v2.#{hmac}.#{issued_at}"
    end
    private_class_method :authorization_token

    def self.request_kwargs(storage, timeout, remote_storage: nil)
      metadata = {
        'authorization' => "Bearer #{authorization_token(storage)}",
        'client_name' => CLIENT_NAME
      }

      feature_stack = Thread.current[:gitaly_feature_stack]
      feature = feature_stack && feature_stack[0]
      metadata['call_site'] = feature.to_s if feature
      metadata['gitaly-servers'] = address_metadata(remote_storage) if remote_storage
      metadata['x-gitlab-correlation-id'] = Gitlab::CorrelationId.current_id if Gitlab::CorrelationId.current_id

      metadata.merge!(server_feature_flags)

      result = { metadata: metadata }

      # nil timeout indicates that we should use the default
      timeout = default_timeout if timeout.nil?

      return result unless timeout > 0

      deadline = real_time + timeout
      result[:deadline] = deadline

      result
    end

    SERVER_FEATURE_FLAGS = %w[].freeze

    def self.server_feature_flags
      SERVER_FEATURE_FLAGS.map do |f|
        ["gitaly-feature-#{f.tr('_', '-')}", feature_enabled?(f).to_s]
      end.to_h
    end

    def self.token(storage)
      params = Gitlab.config.repositories.storages[storage]
      raise "storage not found: #{storage.inspect}" if params.nil?

      params['gitaly_token'].presence || Gitlab.config.gitaly['token']
    end

    def self.feature_enabled?(feature_name)
      Feature.enabled?("gitaly_#{feature_name}")
    end

    # Ensures that Gitaly is not being abuse through n+1 misuse etc
    def self.enforce_gitaly_request_limits(call_site)
      # Only count limits in request-response environments (not sidekiq for example)
      return unless Gitlab::SafeRequestStore.active?

      # This is this actual number of times this call was made. Used for information purposes only
      actual_call_count = increment_call_count("gitaly_#{call_site}_actual")

      # Do no enforce limits in production
      return if Rails.env.production? || ENV["GITALY_DISABLE_REQUEST_LIMITS"]

      # Check if this call is nested within a allow_n_plus_1_calls
      # block and skip check if it is
      return if get_call_count(:gitaly_call_count_exception_block_depth) > 0

      # This is the count of calls outside of a `allow_n_plus_1_calls` block
      # It is used for enforcement but not statistics
      permitted_call_count = increment_call_count("gitaly_#{call_site}_permitted")

      count_stack

      return if permitted_call_count <= MAXIMUM_GITALY_CALLS

      raise TooManyInvocationsError.new(call_site, actual_call_count, max_call_count, max_stacks)
    end

    def self.allow_n_plus_1_calls
      return yield unless Gitlab::SafeRequestStore.active?

      begin
        increment_call_count(:gitaly_call_count_exception_block_depth)
        yield
      ensure
        decrement_call_count(:gitaly_call_count_exception_block_depth)
      end
    end

    def self.get_call_count(key)
      Gitlab::SafeRequestStore[key] || 0
    end
    private_class_method :get_call_count

    def self.increment_call_count(key)
      Gitlab::SafeRequestStore[key] ||= 0
      Gitlab::SafeRequestStore[key] += 1
    end
    private_class_method :increment_call_count

    def self.decrement_call_count(key)
      Gitlab::SafeRequestStore[key] -= 1
    end
    private_class_method :decrement_call_count

    # Returns the of the number of Gitaly calls made for this request
    def self.get_request_count
      get_call_count("gitaly_call_actual")
    end

    def self.reset_counts
      return unless Gitlab::SafeRequestStore.active?

      Gitlab::SafeRequestStore["gitaly_call_actual"] = 0
      Gitlab::SafeRequestStore["gitaly_call_permitted"] = 0
    end

    def self.add_call_details(details)
      return unless Gitlab::SafeRequestStore[:peek_enabled]

      Gitlab::SafeRequestStore['gitaly_call_details'] ||= []
      Gitlab::SafeRequestStore['gitaly_call_details'] << details
    end

    def self.list_call_details
      return [] unless Gitlab::SafeRequestStore[:peek_enabled]

      Gitlab::SafeRequestStore['gitaly_call_details'] || []
    end

    def self.expected_server_version
      path = Rails.root.join(SERVER_VERSION_FILE)
      path.read.chomp
    end

    def self.timestamp(time)
      Google::Protobuf::Timestamp.new(seconds: time.to_i)
    end

    # The default timeout on all Gitaly calls
    def self.default_timeout
      return no_timeout if Sidekiq.server?

      timeout(:gitaly_timeout_default)
    end

    def self.fast_timeout
      timeout(:gitaly_timeout_fast)
    end

    def self.medium_timeout
      timeout(:gitaly_timeout_medium)
    end

    def self.no_timeout
      0
    end

    def self.timeout(timeout_name)
      Gitlab::CurrentSettings.current_application_settings[timeout_name]
    end
    private_class_method :timeout

    # Count a stack. Used for n+1 detection
    def self.count_stack
      return unless Gitlab::SafeRequestStore.active?

      stack_string = Gitlab::Profiler.clean_backtrace(caller).drop(1).join("\n")

      Gitlab::SafeRequestStore[:stack_counter] ||= Hash.new

      count = Gitlab::SafeRequestStore[:stack_counter][stack_string] || 0
      Gitlab::SafeRequestStore[:stack_counter][stack_string] = count + 1
    end
    private_class_method :count_stack

    # Returns a count for the stack which called Gitaly the most times. Used for n+1 detection
    def self.max_call_count
      return 0 unless Gitlab::SafeRequestStore.active?

      stack_counter = Gitlab::SafeRequestStore[:stack_counter]
      return 0 unless stack_counter

      stack_counter.values.max
    end
    private_class_method :max_call_count

    # Returns the stacks that calls Gitaly the most times. Used for n+1 detection
    def self.max_stacks
      return nil unless Gitlab::SafeRequestStore.active?

      stack_counter = Gitlab::SafeRequestStore[:stack_counter]
      return nil unless stack_counter

      max = max_call_count
      return nil if max.zero?

      stack_counter.select { |_, v| v == max }.keys
    end
    private_class_method :max_stacks
  end
end
