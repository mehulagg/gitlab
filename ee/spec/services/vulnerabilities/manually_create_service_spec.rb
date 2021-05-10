# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Vulnerabilities::ManuallyCreateService do
  before do
    stub_licensed_features(security_dashboard: true)
  end

  let_it_be(:user) { create(:user) }

  let(:project) { create(:project) } # cannot use let_it_be here: caching causes problems with permission-related tests

  subject { described_class.new(project, user, params: params).execute }

  context 'with an authorized user with proper permissions' do
    before do
      project.add_developer(user)
    end

    context 'with valid parameters' do
      let(:scanner_params) do
        {
          name: "My manual scanner"
        }
      end

      let(:identifier_params) do
        {
          name: "Test identifier 1",
          url: "https://test.com"
        }
      end

      let(:params) do
        {
          vulnerability: {
            name: "Test vulnerability",
            state: "detected",
            severity: "unknown",
            confidence: "unknown",
            identifiers: [identifier_params],
            scanner: scanner_params
          }
        }
      end

      it 'creates a new Vulnerability' do
        expect { subject }.to change(Vulnerability, :count).by(1)
      end

      it 'creates a new Finding' do
        expect { subject }.to change(Vulnerabilities::Finding, :count).by(1)
      end

      it 'creates a new Scanner' do
        expect { subject }.to change(Vulnerabilities::Scanner, :count).by(1)
      end

      it 'creates a new Identifier' do
        expect { subject }.to change(Vulnerabilities::Identifier, :count).by(1)
      end

      context 'when Scanner already exists' do
        let!(:scanner) { create(:vulnerabilities_scanner, name: scanner_params[:name]) }

        it 'does not create a new Scanner' do
          expect { subject }.to change(Vulnerabilities::Scanner, :count).by(0)
        end
      end

      context 'when Identifier already exists' do
        let!(:identifier) { create(:vulnerabilities_identifier, name: identifier_params[:name]) }

        it 'does not create a new Identifier' do
          expect { subject }.to change(Vulnerabilities::Identifier, :count).by(0)
        end
      end
    end

    context 'with invalid parameters' do
      let(:params) do
        {
          vulnerability: {
            identifiers: [{
              name: "Test identfier 1",
              url: "https://test.com"
            }],
            scanner: {
              name: "My manual scanner"
            }
          }
        }
      end

      it 'returns an error' do
        expect(subject.error?).to be_truthy
      end
    end
  end

  context 'when user does not have rights to dismiss a vulnerability' do
    let(:params) { {} }

    before do
      project.add_reporter(user)
    end

    it 'raises an "access denied" error' do
      expect { subject }.to raise_error(Gitlab::Access::AccessDeniedError)
    end
  end
end
