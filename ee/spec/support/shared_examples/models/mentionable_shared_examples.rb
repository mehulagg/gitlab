# frozen_string_literal: true

# Specifications for behavior common to all Mentionable implementations.
# Requires a shared context containing:
# - subject { "the mentionable implementation" }
# - let(:backref_text) { "the way that +subject+ should refer to itself in backreferences " }
# - let(:set_mentionable_text) { lambda { |txt| "block that assigns txt to the subject's mentionable_text" } }

RSpec.shared_context 'mentionable context with EE-specific mentions' do
  let(:group) { create(:group) }
  let(:mentioned_epic) { create(:epic, group: group) }
  let(:ref_string) do
    <<-MSG.strip_heredoc
      These references are new:
        Epic:  #{mentioned_epic.to_reference(project)}
    MSG
  end

  before do
    stub_licensed_features(epics: true)
  end
end

RSpec.shared_examples 'a mentionable with EE-specific mentions' do
  include_context 'mentionable context'
  include_context 'mentionable context with EE-specific mentions'

  it "extracts references from its reference property" do
    # De-duplicate and omit itself
    refs = subject.referenced_mentionables

    expect(refs.size).to eq(1)
    expect(refs).to include(mentioned_epic)
  end

  it 'creates cross-reference notes', :clean_gitlab_redis_cache do
    mentioned_objects = [mentioned_epic]

    mentioned_objects.each do |referenced|
      expect(SystemNoteService).to receive(:cross_reference)
        .with(referenced, subject.local_reference, author)
    end

    subject.create_cross_references!
  end
end

RSpec.shared_examples 'an editable mentionable with EE-specific mentions' do
  include_context 'mentionable context'
  include_context 'mentionable context with EE-specific mentions'

  it_behaves_like 'a mentionable with EE-specific mentions'

  let(:new_epic) { create(:epic, group: group) }

  it 'creates new cross-reference notes when the mentionable text is edited' do
    subject.save!
    subject.create_cross_references!

    new_text = <<-MSG.strip_heredoc
      These references already existed:

      Issue:  #{mentioned_epic.to_reference(project)}

      ---

      This reference are introduced in an edit:

      Epic: #{new_epic.to_reference(project)}
    MSG

    # These four objects were already referenced, and should not receive new
    # notes
    [mentioned_epic].each do |oldref|
      expect(SystemNoteService).not_to receive(:cross_reference)
        .with(oldref, any_args)
    end

    # These two issues and an epic are new and should receive reference notes
    # In the case of MergeRequests remember that cannot mention commits included in the MergeRequest
    [new_epic].each do |newref|
      expect(SystemNoteService).to receive(:cross_reference)
        .with(newref, subject.local_reference, author)
    end

    set_mentionable_text.call(new_text)
    subject.create_new_cross_references!(author)
  end
end
