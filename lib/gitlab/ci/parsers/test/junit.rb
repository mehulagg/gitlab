# frozen_string_literal: true

module Gitlab
  module Ci
    module Parsers
      module Test
        class Junit
          JunitParserError = Class.new(Gitlab::Ci::Parsers::ParserError)
          ATTACHMENT_TAG_REGEX = /\[\[ATTACHMENT\|(?<path>.+?)\]\]/.freeze

          def parse!(xml_data, test_suite, **args)
            all_cases(xml_data).each do |test_case_node|
              test_case = create_test_case(test_case_node, args)
              test_suite.add_test_case(test_case)
            end
          rescue Nokogiri::XML::SyntaxError => e
            test_suite.set_suite_error("JUnit XML parsing failed: #{e}")
          rescue StandardError => e
            test_suite.set_suite_error("JUnit data parsing failed: #{e}")
          end

          private

          def all_cases(xml_data)
            doc = Nokogiri.XML(xml_data)
            raise doc.errors.first if doc.errors.any?

            doc.xpath("//testcase")
          end

          def create_test_case(test_case_node, args)
            non_success = test_case_node.xpath('failure', 'error', 'skipped').first
            system_out = test_case_node.xpath('system-out').first

            case non_success&.name
            when 'failure'
              status = ::Gitlab::Ci::Reports::TestCase::STATUS_FAILED
              system_output = non_success.content
              attachment = attachment_path(system_out&.content)
            when 'error'
              status = ::Gitlab::Ci::Reports::TestCase::STATUS_ERROR
              system_output = non_success.content
            when 'skipped'
              status = ::Gitlab::Ci::Reports::TestCase::STATUS_SKIPPED
              system_output = non_success.content
            else
              status = ::Gitlab::Ci::Reports::TestCase::STATUS_SUCCESS
              system_output = nil
            end

            ::Gitlab::Ci::Reports::TestCase.new(
              suite_name: test_case_node.parent['name'],
              classname: test_case_node['classname'],
              name: test_case_node['name'],
              file: test_case_node['file'],
              execution_time: test_case_node['time'],
              status: status,
              system_output: system_output.presence,
              attachment: attachment,
              job: args.fetch(:job)
            )
          end

          def attachment_path(data)
            return unless data

            matches = data.match(ATTACHMENT_TAG_REGEX)
            matches[:path] if matches
          end
        end
      end
    end
  end
end
