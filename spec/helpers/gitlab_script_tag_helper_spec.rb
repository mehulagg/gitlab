# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabScriptTagHelper do
  describe 'script tag' do
    script_url = 'test.js'

    before do
      allow_any_instance_of(GitlabScriptTagHelper).to receive(:content_security_policy_nonce).and_return('noncevalue')
    end

    it 'returns an script tag with defer=true' do
      expect(javascript_include_tag(script_url).to_s)
        .to eq "<script src=\"/javascripts/#{script_url}\" defer=\"defer\" nonce=\"noncevalue\"></script>"
    end
  end
end
