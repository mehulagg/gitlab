# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Packages::DestroyService do
  let_it_be(:user) { create(:user) }

  let!(:package) { create(:npm_package) }

  describe '#execute' do
    subject { described_class.new(container: package, current_user: user).execute }

    context 'when the destroy is successfull' do
      it 'destroy the package' do
        expect(package).to receive(:sync_maven_metadata).and_call_original
        expect { subject }.to change { Packages::Package.count }.by(-1)
      end
    end

    context 'when the destroy is not successful' do
      before do
        allow(package).to receive(:destroy!).and_raise(StandardError, "test")
      end

      it 'throws an error' do
        expect { subject }.to raise_error(StandardError, "test")
      end
    end
  end
end
