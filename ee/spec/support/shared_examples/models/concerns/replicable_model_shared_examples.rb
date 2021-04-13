# frozen_string_literal: true

# Required let variables:
#
# - model_record: A valid, unpersisted instance of the model class. Or a valid,
#                 persisted instance of the model class in a not-yet loaded let
#                 variable (so we can trigger creation).
# - replicator_class
#
# Also see ee/spec/lib/gitlab/geo/replicable_model_spec.rb:
#
# - Place tests in replicable_model_spec.rb if you want to run them once,
#   against a DummyModel.
# - Place tests here in replicable_model_shared_examples.rb if you want them to
#   be run against every real Model.
RSpec.shared_examples 'a replicable model' do
  include EE::GeoHelpers

  describe '#replicator' do
    it 'is defined and does not raise error' do
      expect(model_record.replicator).to be_a(Gitlab::Geo::Replicator)
    end
  end

  it 'invokes replicator.handle_after_create_commit on create' do
    expect_next_instance_of(replicator_class) do |replicator|
      expect(replicator).to receive(:handle_after_create_commit)
    end

    model_record.save!
  end

  describe '.replicables_for_current_secondary' do
    let_it_be(:secondary) { create(:geo_node) }

    before do
      stub_current_geo_node(secondary)
    end

    it 'is implemented' do
      expect(model_record.class.replicables_for_current_secondary(model_record.id)).to be_an(ActiveRecord::Relation)
    end
  end
end
