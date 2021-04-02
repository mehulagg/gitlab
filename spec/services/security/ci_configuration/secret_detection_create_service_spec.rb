# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Security::CiConfiguration::SecretDetectionCreateService, :snowplow do
  let(:snowplow_event) do
    {
      category: 'Security::CiConfiguration::SecretDetectionCreateService',
      action: 'create',
      label: ''
    }
  end

  include_examples 'services security ci configuration create service', true # skip_w_params
end
