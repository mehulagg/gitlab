require 'spec_helper'

describe MergeRequestsHelper do
  include ProjectForksHelper
  describe 'ci_build_details_path' do
    let(:project) { create(:project) }
    let(:merge_request) { MergeRequest.new }
    let(:ci_service) { CiService.new }
    let(:last_commit) { Ci::Pipeline.new({}) }

    before do
      allow(merge_request).to receive(:source_project).and_return(project)
      allow(merge_request).to receive(:last_commit).and_return(last_commit)
      allow(project).to receive(:ci_service).and_return(ci_service)
      allow(last_commit).to receive(:sha).and_return('12d65c')
    end

    it 'does not include api credentials in a link' do
      allow(ci_service)
        .to receive(:build_page).and_return("http://secretuser:secretpass@jenkins.example.com:8888/job/test1/scm/bySHA1/12d65c")
      expect(helper.ci_build_details_path(merge_request)).not_to match("secret")
    end
  end

  describe '#format_mr_branch_names' do
    describe 'within the same project' do
      let(:merge_request) { create(:merge_request) }
      subject { format_mr_branch_names(merge_request) }

      it { is_expected.to eq([merge_request.source_branch, merge_request.target_branch]) }
    end

    describe 'within different projects' do
      let(:project) { create(:project) }
      let(:forked_project) { fork_project(project) }
      let(:merge_request) { create(:merge_request, source_project: forked_project, target_project: project) }
      subject { format_mr_branch_names(merge_request) }
      let(:source_title) { "#{forked_project.full_path}:#{merge_request.source_branch}" }
      let(:target_title) { "#{project.full_path}:#{merge_request.target_branch}" }

      it { is_expected.to eq([source_title, target_title]) }
    end
  end

  describe '#render_items_list' do
    it "returns one item in the list" do
      expect(render_items_list(["user"])).to eq("user")
    end

    it "returns two items in the list" do
      expect(render_items_list(%w(user user1))).to eq("user and user1")
    end

    it "returns three items in the list" do
      expect(render_items_list(%w(user user1 user2))).to eq("user, user1 and user2")
    end
  end
end
