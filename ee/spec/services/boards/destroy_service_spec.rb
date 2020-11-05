# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Boards::DestroyService do
  describe '#execute' do
    let_it_be(:project) { create(:project) }
    let_it_be(:group) { create(:group) }

    shared_examples 'remove the board' do |parent_name|
      let(:parent) { public_send(parent_name) }
      let!(:board) { create(:board, parent_name => parent) }

      subject(:service) { described_class.new(parent, double) }

      context "when #{parent_name} have more than one board" do
        it "removes board from #{parent_name}" do
          create(:board, parent_name => parent)

          expect do
            expect(service.execute(board)).to be_success
          end.to change(parent.boards, :count).by(-1)
        end
      end

      context "when #{parent_name} have one board" do
        it "does not remove board from #{parent_name}" do
          expect do
            expect(service.execute(board)).to be_error
          end.not_to change(parent.boards, :count)
        end
      end
    end

    it_behaves_like 'remove the board', :group
    it_behaves_like 'remove the board', :project
  end
end
