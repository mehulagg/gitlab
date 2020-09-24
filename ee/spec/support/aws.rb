# frozen_string_literal: true

RSpec.configure do |config|
  config.around(:each, :aws_s3) do |example|
    (Aws.config[:s3] ||= {})[:stub_responses] = true
    example.run
  ensure
    Aws.config[:s3].delete(:stub_responses)
  end
end
