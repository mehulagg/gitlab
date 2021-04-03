# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GpgKeysFinder do
  let(:params) { {} }

  let_it_be(:gpg_key_1) { create(:gpg_key) }
  let_it_be(:gpg_key_2) { create(:another_gpg_key) }

  subject { described_class.new(**params).execute }

  describe '#execute' do
    context 'with no parameters' do
      it 'returns all GPG keys' do
        expect(subject).to contain_exactly(gpg_key_1, gpg_key_2)
      end
    end

    context 'with defined user parameters' do
      let(:params) do
        { users: [gpg_key_1.user] }
      end

      it 'returns gpg keys belonging to those users' do
        expect(subject).to contain_exactly(gpg_key_1)
      end
    end
  end
end
