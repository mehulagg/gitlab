# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Analytics::CycleAnalytics::StageEvents::IssueLabelAdded do
  it_behaves_like 'cycle analytics event' do
    let(:params) { { label: GroupLabel.new } }
  end
end
