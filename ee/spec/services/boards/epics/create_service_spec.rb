# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Boards::Epics::CreateService, services: true do
  def created_board
    service.execute.payload
  end

  let(:parent) { create(:group) }

  context 'With epics feature available' do
    before do
      stub_licensed_features(epics: true)
    end

    context 'with valid params' do
      subject(:service) { described_class.new(parent, double, name: 'Backend') }

      it 'creates a new board' do
        expect { service.execute }.to change(parent.boards, :count).by(1)
      end

      it 'returns a successful response' do
        expect(service.execute).to be_success
      end

      it 'creates the default lists' do
        board = created_board

        expect(board.lists.size).to eq 2
        expect(board.lists.first).to be_backlog
        expect(board.lists.last).to be_closed
      end

      it 'does not create a second board' do
        service = described_class.new(parent, double)

        expect(service.execute.payload).not_to be_nil
        expect { service.execute }.not_to change(parent.boards, :count)
      end
    end

    context 'with invalid params' do
      subject(:service) { described_class.new(parent, double, name: nil) }

      it 'does not create a new parent board' do
        expect { service.execute }.not_to change(parent.boards, :count)
      end

      it 'returns an error response' do
        expect(service.execute).to be_error
      end

      it "does not create board's default lists" do
        expect(created_board.lists.size).to eq 0
      end
    end

    context 'without params' do
      subject(:service) { described_class.new(parent, double) }

      it 'creates a new parent board' do
        expect { service.execute }.to change(parent.boards, :count).by(1)
      end

      it 'returns a successful response' do
        expect(service.execute).to be_success
      end

      it "creates board's default lists" do
        board = created_board

        expect(board.lists.size).to eq 2
        expect(board.lists.last).to be_closed
      end
    end
  end
end
