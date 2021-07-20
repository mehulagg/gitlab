# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Banzai::Filter::JiraPrivateImageLinkFilter do
  include FilterSpecHelper

  let_it_be(:project) { create(:project) }
  let_it_be(:jira_integration) { create(:jira_integration, project: project) }
  let_it_be(:context) { { project: project } }

  context 'with a Jira private image' do
    let(:img_link) { '/secure/attachment/10017/10017_jira-logo.jpg' }
    let(:doc) { filter("<img src=\"#{img_link}\">", context) }

    it 'replaces the Jira private images with the link to the image' do
      expect(doc.to_html).to eq("<a class=\"with-attachment-icon\" href=\"#{jira_integration.url}#{img_link}\">#{jira_integration.url}#{img_link}</a>")
    end

    it 'includes the Atlassian referrer on gitlab.com' do
      allow(Gitlab).to receive(:com?).and_return(true)
      referrer = Integrations::Jira::ATLASSIAN_REFERRER_GITLAB_COM.to_query

      expect(doc.to_html).to include("?#{referrer}")
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
