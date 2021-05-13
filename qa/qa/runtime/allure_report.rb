# frozen_string_literal: true

module QA
  module Runtime
    class AllureReport
      # Configure allure reports
      #
      # @return [void]
      def self.configure!
        return unless ENV["GENERATE_ALLURE_REPORT"] == "true"

        require "allure-rspec"

        AllureRspec.configure do |config|
          config.results_directory = "tmp/allure-results"
          config.clean_results_directory = true
        end

        Capybara::Screenshot.after_save_screenshot do |path|
          Allure.add_attachment(
            name: "screenshot",
            source: File.open(path),
            type: Allure::ContentType::PNG,
            test_case: true
          )
        end
        Capybara::Screenshot.after_save_html do |path|
          Allure.add_attachment(
            name: "html",
            source: File.open(path),
            type: "text/html",
            test_case: true
          )
        end

        RSpec.configure do |config|
          config.formatter = AllureRspecFormatter

          config.before do |example|
            testcase = example.metadata[:testcase]
            example.tms("Testcase", testcase) if testcase

            issue = example.metadata.dig(:quarantine, :issue)
            example.issue("Issue", issue) if issue

            example.add_link(name: "Job(#{ENV['CI_JOB_NAME']})", url: ENV["CI_JOB_URL"]) if ENV["CI"]
          end
        end
      end
    end
  end
end
