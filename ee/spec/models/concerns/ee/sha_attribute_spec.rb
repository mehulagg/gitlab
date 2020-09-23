# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EE::ShaAttribute do
  let(:model) { Class.new { include ShaAttribute } }

  before do
    columns = [
      double(:column, name: 'name', type: :text),
      double(:column, name: 'sha1', type: :binary)
    ]

    allow(model).to receive(:columns).and_return(columns)
  end

  describe '#sha_attribute' do
    context 'when in non-production' do
      before do
        stub_rails_env('production')
      end

      context 'when Geo database is not configured' do
        it 'allows the attribute to be added' do
          allow(model).to receive(:table_exists?).and_raise(Geo::TrackingBase::SecondaryNotConfigured.new)

          expect(model).not_to receive(:columns)
          expect(model).to receive(:attribute)

          model.sha_attribute(:name)
        end
      end
    end
  end
end
