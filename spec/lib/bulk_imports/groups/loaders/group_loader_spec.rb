# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BulkImports::Groups::Loaders::GroupLoader do
  describe '#load' do
    let(:user) { create(:user) }
    let(:data) { { foo: :bar } }
    let(:service_double) { instance_double(::Groups::CreateService) }
    let(:context) do
      instance_double(
        BulkImports::Pipeline::Context,
        current_user: user
      )
    end

    subject { described_class.new }

    it 'calls Group Create Service to create a new group' do
      expect(::Groups::CreateService).to receive(:new).with(context.current_user, data).and_return(service_double)
      expect(service_double).to receive(:execute)

      subject.load(context, data)
    end
  end
end
