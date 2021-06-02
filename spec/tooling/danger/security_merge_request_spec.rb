# frozen_string_literal: true

require 'gitlab-dangerfiles'
require 'gitlab/dangerfiles/spec_helper'

require_relative '../../../tooling/danger/security_merge_request'
require_relative '../../../tooling/danger/project_helper'

RSpec.describe Tooling::Danger::SecurityMergeRequest do
  include_context 'with dangerfile'

  let(:fake_danger) do
    DangerSpecHelper.fake_danger.include(described_class)
  end

  subject(:security_merge_request) do
    fake_danger.new(helper: fake_helper)
  end

  describe '#check!' do
    context 'with a canonical merge request' do
      before do
        allow(fake_helper)
          .to receive(:security_mr?)
          .and_return(false)
      end

      it 'returns nothing' do
        expect(security_merge_request.check!).to be_nil
      end
    end

    context 'with a security merge request' do
      before do
        allow(fake_helper)
          .to receive(:security_mr?)
          .and_return(true)
      end

      context 'with a feature flag' do
        it 'fails' do
          files = [
            'app/models/project.rb',
            'config/feature_flags/development/entry.yml'
          ]

          allow(fake_helper)
            .to receive(:all_changed_files)
            .and_return(files)

          expect do
            security_merge_request.check!
          end.to raise_error(RuntimeError)
        end
      end

      context 'without a feature flag' do
        it 'returns nothing' do
          allow(fake_helper)
            .to receive(:all_changed_files)
            .and_return([])

          expect(security_merge_request.check!).to be_nil
        end
      end
    end
  end
end
