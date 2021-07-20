# frozen_string_literal: true

require 'spec_helper'

RSpec.shared_examples 'body shared examples' do |container_type|
  it 'truncates the body to field length' do
    max_body_length = Vulnerabilities::Finding::Evidence::WithBody::MAX_BODY_LENGTH
    container = build(container_type, body: '0' * max_body_length * 2)

    expect(container.body.length).to eq(max_body_length * 2)
    container.validate
    expect(container.body.length).to eq(max_body_length)
  end
end
