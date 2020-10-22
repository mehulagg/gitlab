# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::ReferenceExtractor do
  let(:group)   { create(:group) }
  let(:project) { create(:project, group: group) }

  before do
    group.add_developer(project.creator)
  end

  subject { described_class.new(project, project.creator) }

  it 'accesses valid epics' do
    stub_licensed_features(epics: true)

    @e0 = create(:epic, group: group)
    @e1 = create(:epic, group: group)
    @e2 = create(:epic, group: create(:group, :private))

    text = "#{@e0.to_reference(group, full: true)}, &#{non_existing_record_iid}, #{@e1.to_reference(group, full: true)}, #{@e2.to_reference(group, full: true)}"

    subject.analyze(text, { group: group })

    expect(subject.epics).to match_array([@e0, @e1])
  end
end
