# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Middleware::ReadOnly do
  context 'when maintenance mode is on' do
    before do
      stub_application_setting(maintenance_mode: true)
    end

    it_behaves_like 'write access for a read-only GitLab (EE) instance in maintenance mode'
  end

  context 'when maintenance mode is not on' do
    before do
      stub_application_setting(maintenance_mode: false)
    end

    it_behaves_like 'write access for a read-only GitLab (EE) instance'
  end
end
