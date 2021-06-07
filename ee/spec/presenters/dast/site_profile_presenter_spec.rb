# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Dast::SiteProfilePresenter do
  let_it_be(:project) { create(:project) }
  let_it_be(:dast_site_profile, reload: true) { create(:dast_site_profile, project: project) }

  let(:presenter) { described_class.new(dast_site_profile) }

  shared_examples 'a DAST on-demand secret variable' do
    context 'when there is no associated secret variable' do
      it { is_expected.to be_nil }
    end

    context 'when there an associated secret variable' do
      it 'is redacted' do
        create(:dast_site_profile_secret_variable, dast_site_profile: dast_site_profile, key: key)

        expect(subject).to eq(redacted_value)
      end
    end
  end

  describe '#password' do
    let(:key) { Dast::SiteProfileSecretVariable::PASSWORD }
    let(:redacted_value) { described_class::REDACTED_PASSWORD }

    subject { presenter.password }

    it_behaves_like 'a DAST on-demand secret variable'
  end

  describe '#request_headers' do
    let(:key) { Dast::SiteProfileSecretVariable::REQUEST_HEADERS }
    let(:redacted_value) { described_class::REDACTED_REQUEST_HEADERS }

    subject { presenter.request_headers }

    it_behaves_like 'a DAST on-demand secret variable'
  end
end
