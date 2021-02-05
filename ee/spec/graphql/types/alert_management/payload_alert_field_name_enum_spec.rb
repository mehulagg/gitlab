# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['AlertManagementPayloadAlertFieldName'] do
  it 'exposes all alert field names' do
    expect(described_class.values.keys).to match_array(
      %w[TITLE DESCRIPTION START_TIME END_TIME SERVICE MONITORING_TOOL HOSTS SEVERITY FINGERPRINT GITLAB_ENVIRONMENT_NAME]
    )
  end
end
