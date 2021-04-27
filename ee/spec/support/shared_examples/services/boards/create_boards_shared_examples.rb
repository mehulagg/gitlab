# frozen_string_literal: true

RSpec.shared_examples 'create a board' do |scope|
  let_it_be(:user) { create(:user) }

  context 'with valid params' do
    subject(:service) { described_class.new(parent, user, name: 'Backend') }

    it 'creates a new board' do
      expect { service.execute }.to change(parent.send(scope), :count).by(1)
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
  end

  context 'with invalid params' do
    subject(:service) { described_class.new(parent, user, name: nil) }

    it 'does not create a new parent board' do
      expect { service.execute }.not_to change(parent.send(scope), :count)
    end

    it 'returns an error response' do
      expect(service.execute).to be_error
    end

    it "does not create board's default lists" do
      expect(created_board.lists.size).to eq 0
    end
  end

  context 'without params' do
    subject(:service) { described_class.new(parent, user) }

    it 'creates a new parent board' do
      expect { service.execute }.to change(parent.send(scope), :count).by(1)
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
