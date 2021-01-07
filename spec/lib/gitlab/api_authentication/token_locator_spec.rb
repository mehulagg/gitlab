# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::APIAuthentication::TokenLocator do
  let_it_be(:user) { create(:user) }
  let_it_be(:project, reload: true) { create(:project, :public) }
  let_it_be(:personal_access_token) { create(:personal_access_token, user: user) }
  let_it_be(:ci_job) { create(:ci_build, project: project, user: user, status: :running) }
  let_it_be(:ci_job_done) { create(:ci_build, project: project, user: user, status: :success) }
  let_it_be(:deploy_token) { create(:deploy_token, read_package_registry: true, write_package_registry: true) }

  describe '.new' do
    context 'with a valid type' do
      it 'creates a new instance' do
        expect(described_class.new(:http_basic_auth)).to be_a(described_class)
      end
    end

    context 'with an invalid type' do
      it 'raises ActiveModel::ValidationError' do
        expect { described_class.new(:not_a_real_locator) }.to raise_error(ActiveModel::ValidationError)
      end
    end
  end

  describe '#extract' do
    let(:locator) { described_class.new(type) }

    subject { locator.extract(request) }

    context 'with :http_basic_auth' do
      let(:type) { :http_basic_auth }

      context 'without credentials' do
        let(:request) { double(authorization: nil) }

        it 'returns nil' do
          expect(subject).to be(nil)
        end
      end

      context 'with credentials' do
        let(:username) { 'foo' }
        let(:password) { 'bar' }
        let(:request) { double(authorization: "Basic #{::Base64.strict_encode64("#{username}:#{password}")}") }

        it 'returns the credentials' do
          expect(subject.username).to eq(username)
          expect(subject.password).to eq(password)
        end
      end
    end
  end
end
