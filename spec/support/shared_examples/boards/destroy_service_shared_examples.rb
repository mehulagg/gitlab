# frozen_string_literal: true

RSpec.shared_examples 'board destroy service' do
  describe '#execute' do
    let(:parent_name) { parent.is_a?(Project) ? :project : :group }
    let!(:board) { create(board_factory, parent_name => parent) }

    subject(:service) { described_class.new(parent, double) }

    context 'when there is more than one board' do
      let!(:board2) { create(board_factory, parent_name => parent) }

      it 'destroys the board' do
        create(board_factory, parent_name => parent)

        expect do
          expect(service.execute(board)).to be_success
        end.to change(boards, :count).by(-1)
      end
    end

    context 'when there is only one board' do
      it 'does not remove board' do
        expect do
          expect(service.execute(board)).to be_error
        end.not_to change(boards, :count)
      end
    end
  end
end
