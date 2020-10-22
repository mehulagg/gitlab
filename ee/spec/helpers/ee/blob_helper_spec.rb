# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BlobHelper do
  include TreeHelper

  describe '#licenses_for_select' do
    let(:group) { create(:group) }
    let(:project) { create(:project, namespace: group) }

    let(:group_category) { "Group #{group.full_name}" }
    let(:categories) { result.keys }
    let(:by_group) { result[group_category] }
    let(:by_instance) { result['Instance'] }
    let(:by_popular) { result[:Popular] }
    let(:by_other) { result[:Other] }

    subject(:result) { helper.licenses_for_select(project) }

    before do
      stub_ee_application_setting(file_template_project: project)
      group.update_columns(file_template_project_id: project.id)
    end

    it 'returns Group licenses when enabled' do
      stub_licensed_features(custom_file_templates: false, custom_file_templates_for_namespace: true)

      expect(Gitlab::Template::CustomLicenseTemplate)
        .to receive(:all)
        .with(project)
        .and_return([OpenStruct.new(key: 'name', name: 'Name')])

      expect(categories).to contain_exactly(:Popular, :Other, group_category)
      expect(by_group).to contain_exactly({ id: 'name', name: 'Name' })
      expect(by_popular).to be_present
      expect(by_other).to be_present
    end

    it 'returns Instance licenses when enabled' do
      stub_licensed_features(custom_file_templates: true, custom_file_templates_for_namespace: false)

      expect(Gitlab::Template::CustomLicenseTemplate)
        .to receive(:all)
        .with(project)
        .and_return([OpenStruct.new(key: 'name', name: 'Name')])

      expect(categories).to contain_exactly(:Popular, :Other, 'Instance')
      expect(by_instance).to contain_exactly({ id: 'name', name: 'Name' })
      expect(by_popular).to be_present
      expect(by_other).to be_present
    end

    it 'returns no Group or Instance licenses when disabled' do
      stub_licensed_features(custom_file_templates: false, custom_file_templates_for_namespace: false)

      expect(categories).to contain_exactly(:Popular, :Other)
      expect(by_group).to be_nil
      expect(by_instance).to be_nil
      expect(by_popular).to be_present
      expect(by_other).to be_present
    end
  end
end
