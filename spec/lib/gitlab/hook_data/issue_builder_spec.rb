require 'spec_helper'

describe Gitlab::HookData::IssueBuilder do
  set(:issue) { create(:issue) }
  let(:builder) { described_class.new(issue) }

  describe '#build' do
    let(:data) { builder.build }

    it 'includes safe attribute' do
      %w[
        assignee_id
        author_id
        closed_at
        confidential
        created_at
        description
        due_date
        id
        iid
        last_edited_at
        last_edited_by_id
        milestone_id
        moved_to_id
        project_id
        relative_position
        state
        time_estimate
        title
        updated_at
        updated_by_id
      ].each do |key|
        expect(data).to include(key)
      end
    end

    it 'includes additional attrs' do
      expect(data).to include(:total_time_spent)
      expect(data).to include(:human_time_estimate)
      expect(data).to include(:human_total_time_spent)
      expect(data).to include(:assignee_ids)
    end

    context 'when the issue has an image in the description' do
      let(:issue_with_description) { create(:issue, description: 'test![Issue_Image](/uploads/abc/Issue_Image.png)') }
      let(:builder) { described_class.new(issue_with_description) }

      it 'sets the image to use an absolute URL' do
        expect(data[:description]).to eq("test![Issue_Image](#{Settings.gitlab.url}/uploads/abc/Issue_Image.png)")
      end
    end
  end
end
