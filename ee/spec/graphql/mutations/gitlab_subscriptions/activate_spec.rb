# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::GitlabSubscriptions::Activate do
  include AdminModeHelper

  subject(:mutation) { described_class.new(object: nil, context: { current_user: user }, field: nil) }

  let_it_be(:user) { create(:admin) }
  let_it_be(:created_license) { License.last }

  let(:activation_code) { 'activation_code' }
  let(:result) { { success: true, license: created_license } }

  describe '#resolve' do
    before do
      enable_admin_mode!(user)

      allow_next_instance_of(::GitlabSubscriptions::ActivateService) do |service|
        expect(service).to receive(:execute).with(activation_code).and_return(result)
      end
    end

    context 'when successful' do
      it 'adds the issue to the epic' do
        result = mutation.resolve(activation_code: activation_code)

        expect(result).to eq({ errors: [], license: created_license })
      end
    end

    context 'when failure' do
      let(:result) { { success: false, errors: ['foo'] } }

      it 'returns errors' do
        result = mutation.resolve(activation_code: activation_code)

        expect(result).to eq({ errors: ['foo'], license: nil })
      end
    end

    context 'when non-admin' do
      let_it_be(:user) { create(:user) }

      it 'raises errors' do
        expect do
          mutation.resolve(activation_code: activation_code)
        end.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
      end
    end
  end
end
