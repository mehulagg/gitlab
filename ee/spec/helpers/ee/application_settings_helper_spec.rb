# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EE::ApplicationSettingsHelper do
  describe '.visible_attributes' do
    context 'personal access token parameters' do
      it { expect(visible_attributes).to include(*%i(max_personal_access_token_lifetime enforce_pat_expiration)) }
    end
  end
end
