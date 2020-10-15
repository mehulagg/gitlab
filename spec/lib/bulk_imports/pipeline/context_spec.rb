# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BulkImports::Pipeline::Context do
  describe '#initialize' do
    it 'initializes with permitted attributes' do
      args = {
        current_user: create(:user),
        entities: [],
        configuration: create(:bulk_import_configuration)
      }

      context = described_class.new(args)

      args.each do |k, v|
        expect(context.public_send(k)).to eq(v)
      end
    end

    context 'when invalid argument is passed' do
      it 'raises ArgumentError' do
        expect { described_class.new(test: 'test') }.to raise_exception(ArgumentError)
      end
    end
  end
end
