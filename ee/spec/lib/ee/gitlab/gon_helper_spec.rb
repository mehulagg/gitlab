# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::GonHelper do
  let(:helper) do
    Class.new do
      include Gitlab::GonHelper
    end.new
  end

  describe '#push_licensed_feature' do
    let_it_be(:feature) { License::EEU_FEATURES.first }

    shared_examples 'sets the licensed features flag' do
      it 'pushes the licensed feature flag to the frotnend' do
        gon = instance_double('gon')
        stub_licensed_features(feature => true)

        allow(helper)
          .to receive(:gon)
          .and_return(gon)

        expect(gon)
          .to receive(:push)
          .with({ licensed_features: { feature.to_s.camelize(:lower) => true } }, true)

        subject
      end
    end

    context 'no obj given' do
      subject { helper.push_licensed_feature(feature) }

      before do
        expect(License).to receive(:feature_available?).with(feature)
      end

      it_behaves_like 'sets the licensed features flag'
    end

    context 'obj given' do
      let(:project) { create(:project) }

      subject { helper.push_licensed_feature(feature, project) }

      before do
        expect(project).to receive(:feature_available?).with(feature).and_call_original
      end

      it_behaves_like 'sets the licensed features flag'
    end
  end
end
