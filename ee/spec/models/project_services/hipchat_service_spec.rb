# frozen_string_literal: true

require 'spec_helper'

RSpec.describe HipchatService do
  let(:hipchat) { described_class.new }
  let(:user)    { create(:user) }
  let(:project) { create(:project, :repository) }
  let(:api_url) { 'https://hipchat.example.com/v2/room/123456/notification?auth_token=verySecret' }
  let(:project_name) { project.full_name.gsub(/\s/, '') }
  let(:token) { 'verySecret' }
  let(:server_url) { 'https://hipchat.example.com'}
  let(:merge_request) { create(:merge_request, description: '**please** fix', title: 'Awesome merge request', target_project: project, source_project: project) }
  let(:merge_service) { MergeRequests::CreateService.new(project, user) }
  let(:approved_merge_sample_data) { merge_service.hook_data(merge_request, 'approved') }

  before do
    allow(hipchat).to receive_messages(
      project_id: project.id,
      project: project,
      room: 123456,
      server: server_url,
      token: token
    )
    WebMock.stub_request(:post, api_url)
  end

  it 'creates a message for approved merge requests' do
    message = hipchat.send(:create_merge_request_message, approved_merge_sample_data)

    obj_attr = approved_merge_sample_data[:object_attributes]
    expect(message).to eq("#{user.name} approved " \
                          "<a href=\"#{obj_attr[:url]}\">merge request !#{obj_attr['iid']}</a> in " \
                          "<a href=\"#{project.web_url}\">#{project_name}</a>: " \
                          '<b>Awesome merge request</b>' \
                          '<pre><strong>please</strong> fix</pre>')
  end
end
