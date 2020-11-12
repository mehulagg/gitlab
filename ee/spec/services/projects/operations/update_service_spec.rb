# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::Operations::UpdateService do
  let_it_be_with_refind(:project) { create(:project) }
  let_it_be(:user) { create(:user) }

  let(:result) { subject.execute }

  subject { described_class.new(project, user, params) }

  describe '#execute' do
    context 'status page setting' do
      before_all do
        project.add_maintainer(user)
      end

      shared_examples 'no operation' do
        it 'does nothing' do
          expect(result[:status]).to eq(:success)
          expect(project.reload.status_page_setting).to be_nil
        end
      end

      context 'with valid params' do
        let(:params) do
          {
            status_page_setting_attributes: attributes_for(:status_page_setting, aws_s3_bucket_name: 'test')
          }
        end

        context 'with an existing setting' do
          before do
            create(:status_page_setting, project: project)
          end

          it 'updates the setting' do
            expect(project.status_page_setting).not_to be_nil

            expect(result[:status]).to eq(:success)
            expect(project.reload.status_page_setting.aws_s3_bucket_name)
              .to eq('test')
          end

          context 'with aws key and secret blank' do
            let(:params) do
              {
                status_page_setting_attributes: {
                  aws_access_key: '',
                  aws_secret_key: '',
                  aws_s3_bucket_name: '',
                  aws_region: '',
                  status_page_url: ''
                }
              }
            end

            it 'destroys the status_page_setting entry in DB' do
              expect(result[:status]).to eq(:success)

              expect(project.reload.status_page_setting).to be_nil
            end
          end

          context 'with not all keys blank' do
            let(:params) do
              {
                status_page_setting_attributes: {
                  aws_s3_bucket_name: 'test',
                  aws_region: 'ap-southeast-2',
                  aws_access_key: '',
                  aws_secret_key: project.reload.status_page_setting.masked_aws_secret_key,
                  status_page_url: 'https://status.gitlab.com'
                }
              }
            end

            it 'returns a validation error' do
              expect(result[:status]).to eq(:error)
            end
          end
        end

        context 'without an existing setting' do
          it 'creates a setting' do
            expect(project.status_page_setting).to be_nil

            expect(result[:status]).to eq(:success)
            expect(project.reload.status_page_setting.aws_s3_bucket_name)
              .to eq('test')
          end
        end
      end
    end
  end
end
