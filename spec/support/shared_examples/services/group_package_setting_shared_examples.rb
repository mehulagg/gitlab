# frozen_string_literal: true

RSpec.shared_examples 'updating the group package setting attributes' do |mode:, from: {}, to:|
  if mode == :create
    it 'creates a new group package setting' do
      expect { subject }
        .to change { group.reload.group_package_setting.present? }.from(false).to(true)
        .and change { GroupPackageSetting.count }.by(1)
    end
  else
    it_behaves_like 'not creating the group package setting'
  end

  it 'updates the group package setting' do
    if from.empty?
      subject

      expect(group_package_setting.reload.maven_duplicates_allowed).to eq(to[:maven_duplicates_allowed])
      expect(group_package_setting.maven_duplicate_exception_regex).to eq(to[:maven_duplicate_exception_regex])
    else
      expect { subject }
        .to change { group_package_setting.reload.maven_duplicates_allowed }.from(from[:maven_duplicates_allowed]).to(to[:maven_duplicates_allowed])
        .and change { group_package_setting.reload.maven_duplicate_exception_regex }.from(from[:maven_duplicate_exception_regex]).to(to[:maven_duplicate_exception_regex])
    end
  end
end

RSpec.shared_examples 'not creating the group package setting' do
  it "doesn't create the group package setting" do
    expect { subject }.not_to change { GroupPackageSetting.count }
  end
end

RSpec.shared_examples 'creating the group package setting' do
  it_behaves_like 'updating the group package setting attributes', mode: :create, to: { maven_duplicates_allowed: true, maven_duplicate_exception_regex: '' }

  it_behaves_like 'returning a success'
end
