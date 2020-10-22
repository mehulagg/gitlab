# frozen_string_literal: true

require 'spec_helper'

# rubocop:disable RSpec/FactoriesInMigrationSpecs
RSpec.describe Gitlab::BackgroundMigration::BackfillVersionDataFromGitaly do
  let(:issue) { create(:issue) }

  def perform_worker
    described_class.new.perform(issue.id)
  end

  def create_version(attrs)
    # Use the `:design` factory to create a version that has a
    # correponding Git commit.
    attrs[:issue] ||= issue
    design = create(:design, :with_file, attrs)
    design.versions.first
  end

  def create_version_with_missing_data(attrs = {})
    version = create_version(attrs)
    version.update_columns(author_id: nil)
    version
  end

  it 'correctly sets version author_id and created_at properties from the Git commit' do
    version = create_version_with_missing_data
    commit = issue.project.design_repository.commit(version.sha)

    expect(version).to have_attributes(
      author_id: nil
    )
    expect(commit.author.id).to be_present

    expect { perform_worker }.to(
      change do
        version.reload
        version.author_id
      end
      .from(nil)
      .to(commit.author.id)
    )
  end

  it 'avoids N+1 issues and fetches all User records in one call' do
    author_1, author_2, author_3 = create_list(:user, 3)
    create_version_with_missing_data(author: author_1)
    create_version_with_missing_data(author: author_2)
    create_version_with_missing_data(author: author_3)

    expect(User).to receive(:by_any_email).with(
      array_including(author_1.email, author_2.email, author_3.email),
      confirmed: true
    ).once.and_call_original

    perform_worker
  end

  it 'leaves versions in a valid state' do
    version = create_version_with_missing_data

    expect(version).to be_valid
    expect { perform_worker }.not_to change { version.reload.valid? }
  end

  it 'skips versions that are in projects that are pending deletion' do
    version = create_version_with_missing_data
    version.issue.project.update!(pending_delete: true)

    expect { perform_worker }.not_to(
      change do
        version.reload
        version.author_id
      end
    )
  end
end
# rubocop:enable RSpec/FactoriesInMigrationSpecs
