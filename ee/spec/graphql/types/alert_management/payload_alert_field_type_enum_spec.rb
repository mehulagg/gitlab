# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['AlertManagementPayloadAlertFieldType'] do
  it 'exposes all alert field types' do
    expect(described_class.values.keys).to match_array(%w[ARRAY DATETIME STRING])
  end
end
