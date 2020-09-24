# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ProjectTracingSetting do
  describe '#external_url' do
    let_it_be(:project) { create(:project) }

    let(:tracing_setting) { project.build_tracing_setting }

    it 'accepts a valid url' do
      tracing_setting.external_url = "https://gitlab.com"

      expect(tracing_setting).to be_valid

      expect { tracing_setting.save! }.not_to raise_error
    end

    it 'fails with an invalid url' do
      tracing_setting.external_url = "gitlab.com"
      expect(tracing_setting).not_to be_valid
    end

    it 'fails with a blank string' do
      tracing_setting.external_url = " "
      expect(tracing_setting).not_to be_valid
    end

    it 'sanitizes the url' do
      tracing_setting.external_url = "https://replaceme.com/'><script>alert(document.cookie)</script>"
      expect(tracing_setting).to be_valid
      expect(tracing_setting.external_url).to eq("https://replaceme.com/'&gt;")
    end
  end
end
