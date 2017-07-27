require 'spec_helper'

describe Banzai::Filter::UploadLinkFilter do
  def filter(doc, contexts = {})
    contexts.reverse_merge!({
      project: project
    })

    raw_filter(doc, contexts)
  end

  def raw_filter(doc, contexts = {})
    described_class.call(doc, contexts)
  end

  def image(path)
    %(<img src="#{path}" />)
  end

  def link(path)
    %(<a href="#{path}">#{path}</a>)
  end

  def nested_image(path)
    %(<div><img src="#{path}" /></div>)
  end

  def nested_link(path)
    %(<div><a href="#{path}">#{path}</a></div>)
  end

  let(:project) { create(:empty_project) }

  shared_examples :preserve_unchanged do
    it 'does not modify any relative URL in anchor' do
      doc = filter(link('README.md'))
      expect(doc.at_css('a')['href']).to eq 'README.md'
    end

    it 'does not modify any relative URL in image' do
      doc = filter(image('files/images/logo-black.png'))
      expect(doc.at_css('img')['src']).to eq 'files/images/logo-black.png'
    end
  end

  it 'does not raise an exception on invalid URIs' do
    act = link("://foo")
    expect { filter(act) }.not_to raise_error
  end

  context 'with a valid repository' do
    it 'rebuilds relative URL for a link' do
      doc = filter(link('/uploads/e90decf88d8f96fe9e1389afc2e4a91f/test.jpg'))
      expect(doc.at_css('a')['href'])
        .to eq "#{Gitlab.config.gitlab.url}/#{project.path_with_namespace}/uploads/e90decf88d8f96fe9e1389afc2e4a91f/test.jpg"

      doc = filter(nested_link('/uploads/e90decf88d8f96fe9e1389afc2e4a91f/test.jpg'))
      expect(doc.at_css('a')['href'])
        .to eq "#{Gitlab.config.gitlab.url}/#{project.path_with_namespace}/uploads/e90decf88d8f96fe9e1389afc2e4a91f/test.jpg"
    end

    it 'rebuilds relative URL for an image' do
      doc = filter(image('/uploads/e90decf88d8f96fe9e1389afc2e4a91f/test.jpg'))
      expect(doc.at_css('img')['src'])
        .to eq "#{Gitlab.config.gitlab.url}/#{project.path_with_namespace}/uploads/e90decf88d8f96fe9e1389afc2e4a91f/test.jpg"

      doc = filter(nested_image('/uploads/e90decf88d8f96fe9e1389afc2e4a91f/test.jpg'))
      expect(doc.at_css('img')['src'])
        .to eq "#{Gitlab.config.gitlab.url}/#{project.path_with_namespace}/uploads/e90decf88d8f96fe9e1389afc2e4a91f/test.jpg"
    end

    it 'does not modify absolute URL' do
      doc = filter(link('http://example.com'))
      expect(doc.at_css('a')['href']).to eq 'http://example.com'
    end

    it 'supports Unicode filenames' do
      path = '/uploads/한글.png'
      escaped = Addressable::URI.escape(path)

      # Stub these methods so the file doesn't actually need to be in the repo
      allow_any_instance_of(described_class)
        .to receive(:file_exists?).and_return(true)
      allow_any_instance_of(described_class)
        .to receive(:image?).with(path).and_return(true)

      doc = filter(image(escaped))
      expect(doc.at_css('img')['src']).to match "#{Gitlab.config.gitlab.url}/#{project.path_with_namespace}/uploads/%ED%95%9C%EA%B8%80.png"
    end

    context 'in a geo secondary node' do
      let(:geo_url) { 'http://geo.example.com' }

      before(:each) do
        allow(Gitlab::Geo).to receive(:secondary?) { true }
        allow(Gitlab::Geo).to receive_message_chain(:primary_node, :url) { geo_url }
      end

      it 'rebuilds relative URL for a link' do
        doc = filter(link('/uploads/e90decf88d8f96fe9e1389afc2e4a91f/test.jpg'))
        expect(doc.at_css('a')['href'])
          .to eq "#{geo_url}/#{project.path_with_namespace}/uploads/e90decf88d8f96fe9e1389afc2e4a91f/test.jpg"
      end

      it 'rebuilds relative URL for an image' do
        doc = filter(link('/uploads/e90decf88d8f96fe9e1389afc2e4a91f/test.jpg'))
        expect(doc.at_css('a')['href'])
          .to eq "#{geo_url}/#{project.path_with_namespace}/uploads/e90decf88d8f96fe9e1389afc2e4a91f/test.jpg"
      end

      it 'does not modify absolute URL' do
        doc = filter(link('http://example.com'))
        expect(doc.at_css('a')['href']).to eq 'http://example.com'
      end
    end
  end

  context 'when project context does not exist' do
    let(:upload_link) { link('/uploads/e90decf88d8f96fe9e1389afc2e4a91f/test.jpg') }

    it 'does not raise error' do
      expect { raw_filter(upload_link, project: nil) }.not_to raise_error
    end

    it 'does not rewrite link' do
      doc = raw_filter(upload_link, project: nil)

      expect(doc.to_html).to eq upload_link
    end
  end
end
