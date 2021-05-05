# frozen_string_literal: true

RSpec.shared_examples 'group and projects packages resolver' do
  context 'without sort' do
    let_it_be(:npm_package) { create(:package, project: project) }

    it { is_expected.to contain_exactly(npm_package) }
  end

  context 'with sorting and filtering' do
    let_it_be(:conan_package) do
      create(:conan_package, name: 'bar', project: project, created_at: 1.day.ago, version: "1.0.0", status: 'default')
    end

    let_it_be(:maven_package) do
      create(:maven_package, name: 'foo', project: project, created_at: 1.hour.ago, version: "2.0.0", status: 'error')
    end

    let_it_be(:repository3) do
      create(:maven_package, name: 'baz', project: project, created_at: 1.minute.ago, version: nil)
    end

    [:created_desc, :name_desc, :version_desc, :type_asc].each do |order|
      context "#{order}" do
        let(:args) { { sort: order } }

        it { is_expected.to eq([maven_package, conan_package]) }
      end
    end

    [:created_asc, :name_asc, :version_asc, :type_desc].each do |order|
      context "#{order}" do
        let(:args) { { sort: order } }

        it { is_expected.to eq([conan_package, maven_package]) }
      end
    end
  end
end
