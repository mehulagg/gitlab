# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Banzai::Filter::JiraPrivateImageLinkFilter do
  include FilterSpecHelper

  let_it_be(:project) { create(:project) }
  let_it_be(:jira_service) { create(:jira_service, project: project) }
  let_it_be(:context) { { project: project } }

  context 'with a Jira private image' do
    let(:img_link) { '/secure/attachment/10017/10017_jira-logo.jpg' }

    it 'replaces the Jira private images with the link to the image' do
      doc = filter("<img src=\"#{img_link}\">", context)

      expect(doc.to_html).to eq("<a class=\"with-attachment-icon\" href=\"#{jira_service.url}#{img_link}\">#{jira_service.url}#{img_link}</a>")
    end
  end

  context 'with other image' do
    let(:img_link) { 'http://example.com/image.jpg' }

    it 'keeps the original image' do
      doc = filter("<img src=\"#{img_link}\">", context)

      expect(doc.to_html).to eq("<img src=\"#{img_link}\">")
    end
  end
end
