# frozen_string_literal: true

require 'spec_helper'
require Rails.root.join('db', 'migrate', '20210526222715_backfill_draft_status_on_merge_requests.rb')

RSpec.describe BackfillDraftStatusOnMergeRequests, :migration do
  let(:namespaces)     { table(:namespaces) }
  let(:projects)       { table(:projects) }
  let(:merge_requests) { table(:merge_requests) }

  let(:group)     { namespaces.create!(name: 'gitlab', path: 'gitlab') }
  let(:project)   { projects.create!(namespace_id: group.id) }

  let(:draft_prefixes) { ["[Draft]", "(Draft)", "Draft:", "Draft", "[WIP]", "WIP:", "WIP"] }

  def create_merge_request(title)
    merge_requests.create!(
      state_id: 1,
      target_project_id: project.id,
      target_branch: 'feature1',
      source_branch: 'master',
      title: title
    )
  end

  context "for MRs with #draft? == true titles but draft attribute false" do
    before do
      draft_prefixes.each do |prefix|
        # merge_request = create(:merge_request, title: "#{prefix} This is a title")
        merge_request = create_merge_request("#{prefix} This is a title")
        merge_request.update_columns(draft: false)
      end
    end

    it "updates all draft merge request's draft field to true" do
      expect { disable_migrations_output { migrate! } }
        .to change { MergeRequest.where(draft: false).count }
        .from(draft_prefixes.length).to(0)
    end
  end
end
