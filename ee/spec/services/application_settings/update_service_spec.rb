# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ApplicationSettings::UpdateService do
  let(:user)    { create(:user) }
  let(:setting) { ApplicationSetting.create_from_defaults }
  let(:service) { described_class.new(setting, user, opts) }

  describe '#execute' do
    context 'common params' do
      let(:opts) { { home_page_url: 'http://foo.bar' } }

      it 'properly updates settings with given params' do
        service.execute

        expect(setting.home_page_url).to eql(opts[:home_page_url])
      end
    end

    context 'with valid params' do
      let(:opts) { { repository_size_limit: '100' } }

      it 'returns success params' do
        expect(service.execute).to be(true)
      end
    end

    context 'with invalid params' do
      let(:opts) { { repository_size_limit: '-100' } }

      it 'returns error params' do
        expect(service.execute).to be(false)
      end
    end

    context 'index dependent' do
      using RSpec::Parameterized::TableSyntax

      where(:index_exists, :indexing_enabled, :input_value, :result) do
        false  | false | true | false
        false  | true  | true | true
        true   | false | true | true
        true   | true  | true | true
      end

      with_them do
        before do
          allow(Gitlab::Elastic::Helper.default).to(receive(:index_exists?)).and_return(index_exists)
          allow(service.application_setting).to(receive(:elasticsearch_indexing)).and_return(indexing_enabled)
        end

        let(:opts) { { elasticsearch_indexing: input_value } }

        it 'returns correct result' do
          expect(service.execute).to be(result)
        end
      end
    end

    context 'repository_size_limit assignment as Bytes' do
      let(:service) { described_class.new(setting, user, opts) }

      context 'when param present' do
        let(:opts) { { repository_size_limit: '100' } }

        it 'converts from MB to Bytes' do
          service.execute

          expect(setting.reload.repository_size_limit).to eql(100 * 1024 * 1024)
        end
      end

      context 'when param not present' do
        let(:opts) { { repository_size_limit: '' } }

        it 'does not update due to invalidity' do
          service.execute

          expect(setting.reload.repository_size_limit).to be_zero
        end

        it 'assign nil value' do
          service.execute

          expect(setting.repository_size_limit).to be_nil
        end
      end

      context 'elasticsearch' do
        context 'limiting namespaces and projects' do
          before do
            setting.update!(elasticsearch_indexing: true)
            setting.update!(elasticsearch_limit_indexing: true)
          end

          context 'namespaces' do
            let(:namespaces) { create_list(:namespace, 3) }

            it 'creates ElasticsearchIndexedNamespace objects when given elasticsearch_namespace_ids' do
              opts = { elasticsearch_namespace_ids: namespaces.map(&:id).join(',') }

              expect do
                described_class.new(setting, user, opts).execute
              end.to change { ElasticsearchIndexedNamespace.count }.by(3)
            end

            it 'deletes ElasticsearchIndexedNamespace objects not in elasticsearch_namespace_ids' do
              create :elasticsearch_indexed_namespace, namespace: namespaces.last
              opts = { elasticsearch_namespace_ids: namespaces.first(2).map(&:id).join(',') }

              expect do
                described_class.new(setting, user, opts).execute
              end.to change { ElasticsearchIndexedNamespace.count }.from(1).to(2)

              expect(ElasticsearchIndexedNamespace.where(namespace_id: namespaces.last.id)).not_to exist
            end

            it 'disregards already existing ElasticsearchIndexedNamespace in elasticsearch_namespace_ids' do
              create :elasticsearch_indexed_namespace, namespace: namespaces.first
              opts = { elasticsearch_namespace_ids: namespaces.first(2).map(&:id).join(',') }

              expect do
                described_class.new(setting, user, opts).execute
              end.to change { ElasticsearchIndexedNamespace.count }.from(1).to(2)

              expect(ElasticsearchIndexedNamespace.pluck(:namespace_id)).to eq([namespaces.first.id, namespaces.second.id])
            end
          end

          context 'projects' do
            let(:projects) { create_list(:project, 3) }

            it 'creates ElasticsearchIndexedProject objects when given elasticsearch_project_ids' do
              opts = { elasticsearch_project_ids: projects.map(&:id).join(',') }

              expect do
                described_class.new(setting, user, opts).execute
              end.to change { ElasticsearchIndexedProject.count }.by(3)
            end

            it 'deletes ElasticsearchIndexedProject objects not in elasticsearch_project_ids' do
              create :elasticsearch_indexed_project, project: projects.last
              opts = { elasticsearch_project_ids: projects.first(2).map(&:id).join(',') }

              expect do
                described_class.new(setting, user, opts).execute
              end.to change { ElasticsearchIndexedProject.count }.from(1).to(2)

              expect(ElasticsearchIndexedProject.where(project_id: projects.last.id)).not_to exist
            end

            it 'disregards already existing ElasticsearchIndexedProject in elasticsearch_project_ids' do
              create :elasticsearch_indexed_project, project: projects.first
              opts = { elasticsearch_project_ids: projects.first(2).map(&:id).join(',') }

              expect do
                described_class.new(setting, user, opts).execute
              end.to change { ElasticsearchIndexedProject.count }.from(1).to(2)

              expect(ElasticsearchIndexedProject.pluck(:project_id)).to eq([projects.first.id, projects.second.id])
            end
          end
        end
      end
    end
  end
end
