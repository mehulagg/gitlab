module Gitlab
  module Metrics
    module InfluxDb
      include Gitlab::CurrentSettings
      extend self

      MUTEX = Mutex.new
      private_constant :MUTEX

      def influx_metrics_enabled?
        settings[:enabled] || false
      end

      # Prometheus histogram buckets used for arbitrary code measurements
      EXECUTION_MEASUREMENT_BUCKETS = [0.001, 0.002, 0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1].freeze
      RAILS_ROOT = Rails.root.to_s
      METRICS_ROOT = Rails.root.join('lib', 'gitlab', 'metrics').to_s
      PATH_REGEX = /^#{RAILS_ROOT}\/?/

      def settings
        @settings ||= {
          enabled: current_application_settings[:metrics_enabled],
          pool_size: current_application_settings[:metrics_pool_size],
          timeout: current_application_settings[:metrics_timeout],
          method_call_threshold: current_application_settings[:metrics_method_call_threshold],
          host: current_application_settings[:metrics_host],
          port: current_application_settings[:metrics_port],
          sample_interval: current_application_settings[:metrics_sample_interval] || 15,
          packet_size: current_application_settings[:metrics_packet_size] || 1
        }
      end

      def mri?
        RUBY_ENGINE == 'ruby'
      end

      def method_call_threshold
        # This is memoized since this method is called for every instrumented
        # method. Loading data from an external cache on every method call slows
        # things down too much.
        @method_call_threshold ||= settings[:method_call_threshold]
      end

      def submit_metrics(metrics)
        prepared = prepare_metrics(metrics)

        pool&.with do |connection|
          prepared.each_slice(settings[:packet_size]) do |slice|
            begin
              connection.write_points(slice)
            rescue StandardError
            end
          end
        end
      rescue Errno::EADDRNOTAVAIL, SocketError => ex
        Gitlab::EnvironmentLogger.error('Cannot resolve InfluxDB address. GitLab Performance Monitoring will not work.')
        Gitlab::EnvironmentLogger.error(ex)
      end

      def prepare_metrics(metrics)
        metrics.map do |hash|
          new_hash = hash.symbolize_keys

          new_hash[:tags].each do |key, value|
            if value.blank?
              new_hash[:tags].delete(key)
            else
              new_hash[:tags][key] = escape_value(value)
            end
          end

          new_hash
        end
      end

      def escape_value(value)
        value.to_s.gsub('=', '\\=')
      end

      # Measures the execution time of a block.
      #
      # Example:
      #
      #     Gitlab::Metrics.measure(:find_by_username_duration) do
      #       User.find_by_username(some_username)
      #     end
      #
      # name - The name of the field to store the execution time in.
      #
      # Returns the value yielded by the supplied block.
      def measure(name)
        trans = current_transaction

        return yield unless trans

        real_start = Time.now.to_f
        cpu_start = System.cpu_time

        retval = yield

        cpu_stop = System.cpu_time
        real_stop = Time.now.to_f

        real_time = (real_stop - real_start)
        cpu_time = cpu_stop - cpu_start

        Gitlab::Metrics.histogram("gitlab_#{name}_real_duration_seconds".to_sym,
                                  "Measure #{name}",
                                  Transaction::BASE_LABELS,
                                  EXECUTION_MEASUREMENT_BUCKETS)
          .observe(trans.labels, real_time)

        Gitlab::Metrics.histogram("gitlab_#{name}_cpu_duration_seconds".to_sym,
                                  "Measure #{name}",
                                  Transaction::BASE_LABELS,
                                  EXECUTION_MEASUREMENT_BUCKETS)
          .observe(trans.labels, cpu_time / 1000.0)

        # InfluxDB stores the _real_time time values as milliseconds
        trans.increment("#{name}_real_time", real_time * 1000, false)
        trans.increment("#{name}_cpu_time", cpu_time, false)
        trans.increment("#{name}_call_count", 1, false)

        retval
      end

      # Sets the action of the current transaction (if any)
      #
      # action - The name of the action.
      def action=(action)
        trans = current_transaction

        trans&.action = action
      end

      # Tracks an event.
      #
      # See `Gitlab::Metrics::Transaction#add_event` for more details.
      def add_event(*args)
        current_transaction&.add_event(*args)
      end

      def add_event_with_values(*args)
        current_transaction&.add_event_with_values(*args)
      end

      # Returns the prefix to use for the name of a series.
      def series_prefix
        @series_prefix ||= Sidekiq.server? ? 'sidekiq_' : 'rails_'
      end

      # Allow access from other metrics related middlewares
      def current_transaction
        Transaction.current
      end

      # When enabled this should be set before being used as the usual pattern
      # "@foo ||= bar" is _not_ thread-safe.
      # rubocop:disable Gitlab/ModuleWithInstanceVariables
      def pool
        if influx_metrics_enabled?
          if @pool.nil?
            MUTEX.synchronize do
              @pool ||= ConnectionPool.new(size: settings[:pool_size], timeout: settings[:timeout]) do
                host = settings[:host]
                port = settings[:port]

                InfluxDB::Client
                  .new(udp: { host: host, port: port })
              end
            end
          end
          @pool
        end
      end
      # rubocop:enable Gitlab/ModuleWithInstanceVariables
    end
  end
end
