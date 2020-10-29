# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EE::Gitlab::Checks::PushRuleCheck do
  include_context 'push rules checks context'

  let(:push_rule) { create(:push_rule, :commit_message) }

  shared_examples "push checks" do
    before do
      allow_any_instance_of(EE::Gitlab::Checks::PushRules::FileSizeCheck)
        .to receive(:validate!).and_return(nil)
      allow_any_instance_of(EE::Gitlab::Checks::PushRules::TagCheck)
        .to receive(:validate!).and_return(nil)
      allow_any_instance_of(EE::Gitlab::Checks::PushRules::BranchCheck)
        .to receive(:validate!).and_return(nil)
    end

    it "returns nil on success" do
      expect(subject.validate!).to be_nil
    end

    it "raises an error on failure" do
      expect_any_instance_of(EE::Gitlab::Checks::PushRules::FileSizeCheck).to receive(:validate!).and_raise(Gitlab::GitAccess::ForbiddenError)

      expect { subject.validate! }.to raise_error(Gitlab::GitAccess::ForbiddenError)
    end

    context 'when tag name exists' do
      before do
        allow(change_access).to receive(:tag_name).and_return(true)
      end

      it 'validates tags push rules' do
        expect_any_instance_of(EE::Gitlab::Checks::PushRules::TagCheck)
          .to receive(:validate!)
        expect_any_instance_of(EE::Gitlab::Checks::PushRules::BranchCheck)
          .not_to receive(:validate!)

        subject.validate!
      end
    end

    context 'when tag name does not exists' do
      before do
        allow(change_access).to receive(:tag_name).and_return(false)
      end

      it 'validates branches push rules' do
        expect_any_instance_of(EE::Gitlab::Checks::PushRules::TagCheck)
          .not_to receive(:validate!)
        expect_any_instance_of(EE::Gitlab::Checks::PushRules::BranchCheck)
          .to receive(:validate!)

        subject.validate!
      end
    end
  end

  describe '#validate!' do
    it_behaves_like "push checks"

    context ":parallel_push_checks feature is disabled" do
      before do
        stub_feature_flags(parallel_push_checks: false)
      end

      it_behaves_like "push checks"
    end
  end

  describe "#parallelize" do
    let(:git_env) do
      {
        "GIT_OBJECT_DIRECTORY_RELATIVE" => "foo",
        "GIT_ALTERNATE_OBJECT_DIRECTORIES_RELATIVE" => "bar"
      }
    end

    it "makes the git env available to the child thread" do
      subject.instance_variable_set(:@threads, [])

      subject.send(:parallelize, git_env) do
        expect(::Gitlab::Git::HookEnv.all(project.repository.gl_repository)).to eq(git_env)
      end
    end
  end
end
