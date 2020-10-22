# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Commit do
  it_behaves_like 'a mentionable with EE-specific mentions' do
    subject { create(:project, :repository).commit }

    let(:author) { create(:user, email: subject.author_email) }
    let(:backref_text) { "commit #{subject.id}" }
    let(:set_mentionable_text) do
      ->(txt) { allow(subject).to receive(:safe_message).and_return(txt) }
    end

    # Include the subject in the repository stub.
    let(:extra_commits) { [subject] }
  end
end
