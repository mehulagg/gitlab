# frozen_string_literal: true

module QA
  module Support
    module Retrier
      module_function

      def retry_on_exception(max_attempts: 3, reload_page: nil, sleep_interval: 0.5)
        QA::Runtime::Logger.debug("with retry_on_exception: max_attempts #{max_attempts}; sleep_interval #{sleep_interval}")

        attempts = 0

        begin
          QA::Runtime::Logger.debug("Attempt number #{attempts + 1}")
          yield
        rescue StandardError, RSpec::Expectations::ExpectationNotMetError
          sleep sleep_interval
          reload_page.refresh if reload_page
          attempts += 1

          retry if attempts < max_attempts
          QA::Runtime::Logger.debug("Raising exception after #{max_attempts} attempts")
          raise
        end
      end

      def retry_until(max_attempts: 3, reload_page: nil, sleep_interval: 0, exit_on_failure: false, retry_on_exception: false)
        QA::Runtime::Logger.debug("with retry_until: max_attempts #{max_attempts}; sleep_interval #{sleep_interval}; reload_page:#{reload_page}")
        attempts = 0

        while attempts < max_attempts
          begin
            QA::Runtime::Logger.debug("Attempt number #{attempts + 1}")
            result = yield
            return result if result

            sleep sleep_interval
            reload_page.refresh if reload_page
            attempts += 1
          rescue StandardError, RSpec::Expectations::ExpectationNotMetError
            raise unless retry_on_exception

            attempts += 1
            if attempts < max_attempts
              sleep sleep_interval
              reload_page.refresh if reload_page

              retry
            else
              raise
            end
          end
        end

        if exit_on_failure
          raise "Raising exception after #{max_attempts} attempts"
        end

        false
      end
    end
  end
end
