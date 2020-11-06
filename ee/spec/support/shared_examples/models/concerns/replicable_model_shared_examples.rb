# frozen_string_literal: true

# Required let variables:
#
# - model_record: A valid, unpersisted instance of the model class
#
# We do not use `described_class` here, so we can include this in replicator
# strategy shared examples instead of in *every* model spec.
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
    expect(model_record.replicator).to receive(:handle_after_create_commit)

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

  context 'verification' do
    before do
      # TODO: Remove this skip before releasing verification of all Replicators https://gitlab.com/gitlab-org/gitlab/-/issues/277400
      skip 'not testing verification on anything but Package files at the moment' unless model_record.class == Packages::PackageFile
    end

    describe '.model_record_ids_never_attempted_verification' do
      before do
        model_record.save!
      end

      it 'returns IDs of rows pending verification that never started' do
        expect(model_record.class.model_record_ids_never_attempted_verification(batch_size: 5)).to include(model_record.id)
      end

      it 'marks verification as started' do
        model_record.class.model_record_ids_never_attempted_verification(batch_size: 5)

        expect(model_record.reload.verification_started?).to be_truthy
        expect(model_record.verification_started_at).to be_present
      end
    end
  end
end
