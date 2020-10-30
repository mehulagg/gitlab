# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Service do
  describe '.project_specific_services_names' do
    before do
      allow(::Gitlab).to receive(:com?).and_return(com)
    end

    context 'when not on gitlab.com' do
      let(:com) { false }

      it { expect(described_class.project_specific_services_names).to contain_exactly('github', 'jenkins') }
    end

    context 'when on gitlab.com' do
      let(:com) { true }

      it { expect(described_class.project_specific_services_names).to contain_exactly('github', 'gitlab_slack_application', 'jenkins') }
    end
  end
end
