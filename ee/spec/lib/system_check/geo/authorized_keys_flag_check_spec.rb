# frozen_string_literal: true

require 'spec_helper'
require 'rake_helper'

RSpec.describe SystemCheck::Geo::AuthorizedKeysFlagCheck do
  before do
    silence_output
  end

  describe '#check?' do
    it 'fails when write to authorized_keys still enabled' do
      stub_application_setting(authorized_keys_enabled: true)

      expect(subject.check?).to be_falsey
    end

    it 'succeed when write to authorized_keys is disabled' do
      stub_application_setting(authorized_keys_enabled: false)

      expect(subject.check?).to be_truthy
    end
  end
end
