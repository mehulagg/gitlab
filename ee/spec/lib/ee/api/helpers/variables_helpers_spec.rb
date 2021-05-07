# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EE::API::Helpers::VariablesHelpers do
  let(:klass) { Class.new.include(described_class).new }

  describe '#filter_variable_parameters' do
    let(:params) { { key: 'KEY', environment_scope: 'production' } }

    subject { klass.filter_variable_parameters(owner, params) }

    context 'owner is a project' do
      let(:owner) { create(:project) }

      it { is_expected.to eq(params) }
    end

    context 'owner is a group' do
      let(:owner) { create(:group) }

      before do
        allow(owner).to receive(:scoped_variables_available?).and_return(scoped_variables_available)
      end

      context 'scoped variables are available' do
        let(:scoped_variables_available) { true }

        it { is_expected.to eq(params) }
      end

      context 'scoped variables are not available' do
        let(:scoped_variables_available) { false }

        it { is_expected.to eq(params.except(:environment_scope)) }
      end
    end
  end
end
