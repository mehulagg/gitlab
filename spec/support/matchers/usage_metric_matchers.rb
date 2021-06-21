# frozen_string_literal: true

RSpec::Matchers.define :has_usage_metric do |key_path|
  match do |actual|
    key_path.split('.').each_with_object(actual) do |part, section|
      section = section[part]
      break false unless section
    end
  end

  failure_message do
    "Payload does not contain metric with  key path: '#{key_path}'"
  end
end
