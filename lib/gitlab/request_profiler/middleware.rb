# frozen_string_literal: true

require 'ruby-prof'
require 'memory_profiler'

module Gitlab
  module RequestProfiler
    class Middleware
      def initialize(app)
        @app = app
      end

      def call(env)
        if request_profile?(env)
          call_with_profiling(env)
        elsif sidekiq_profile?(env)
          set_sidekiq_profile_option(env)
          p "FG" * 100
          @app.call(env)
          clear_sidekiq_profile_option
        else
          @app.call(env)
        end
      end

      def set_sidekiq_profile_option(env)
        Thread.current[:profile_sidekiq_worker] = env['HTTP_X_PROFILE_SIDEKIQ_WORKER']
        p "DDDDDD, #{Time.now}  Thread from #{self.class.name}.#{__method__}:line#{__LINE__}: #{Thread.current}, Thread.current[:profile_sidekiq_worker]: #{Thread.current[:profile_sidekiq_worker]}"
      end

      def clear_sidekiq_profile_option
        Thread.current[:profile_sidekiq_worker] = nil
        p "dddddd, #{Time.now}  Thread from #{self.class.name}.#{__method__}:line#{__LINE__}: #{Thread.current}, Thread.current[:profile_sidekiq_worker]: #{Thread.current[:profile_sidekiq_worker]}"
      end

      def request_profile?(env)
        profile?(env) && !sidekiq_profile?(env)
      end

      def sidekiq_profile?(env)
        profile?(env) && env['HTTP_X_PROFILE_SIDEKIQ_WORKER']
      end

      def profile?(env)
        header_token = env['HTTP_X_PROFILE_TOKEN']
        return unless header_token.present?

        profile_token = Gitlab::RequestProfiler.profile_token
        return unless profile_token.present?

        header_token == profile_token
      end

      def call_with_profiling(env)
        case env['HTTP_X_PROFILE_MODE']
        when 'execution', nil
          call_with_call_stack_profiling(env)
        when 'memory'
          call_with_memory_profiling(env)
        else
          raise ActionController::BadRequest, invalid_profile_mode(env)
        end
      end

      def invalid_profile_mode(env)
        <<~HEREDOC
          Invalid X-Profile-Mode: #{env['HTTP_X_PROFILE_MODE']}.
          Supported profile mode request header:
            - X-Profile-Mode: execution
            - X-Profile-Mode: memory
        HEREDOC
      end

      def call_with_call_stack_profiling(env)
        ret = nil
        report = RubyProf::Profile.profile do
          ret = catch(:warden) do
            @app.call(env)
          end
        end

        generate_report(env, 'execution', 'html') do |file|
          printer = RubyProf::CallStackPrinter.new(report)
          printer.print(file)
        end

        handle_request_ret(ret)
      end

      def call_with_memory_profiling(env)
        ret = nil
        report = MemoryProfiler.report do
          ret = catch(:warden) do
            @app.call(env)
          end
        end

        generate_report(env, 'memory', 'txt') do |file|
          report.pretty_print(to_file: file)
        end

        handle_request_ret(ret)
      end

      def generate_report(env, report_type, extension)
        file_name = "#{env['PATH_INFO'].tr('/', '|')}_#{Time.current.to_i}"\
                    "_#{report_type}.#{extension}"
        file_path = "#{PROFILES_DIR}/#{file_name}"

        FileUtils.mkdir_p(PROFILES_DIR)

        begin
          File.open(file_path, 'wb') do |file|
            yield(file)
          end
        rescue
          FileUtils.rm(file_path)
        end
      end

      def handle_request_ret(ret)
        if ret.is_a?(Array)
          ret
        else
          throw(:warden, ret)
        end
      end
    end
  end
end
