# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['AlertManagementPayloadAlertFieldName'] do
  it 'exposes all alert field names' do
    expect(described_class.values.keys).to match_array(
      ::Gitlab::AlertManagement.alert_fields.map { |f| f[:name].upcase }
    )
  end
end
