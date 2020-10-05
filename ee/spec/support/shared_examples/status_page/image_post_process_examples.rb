# frozen_string_literal: true

# This shared_example requires the following variables:
# - object: The AR object
# - field: The entity field/AR attribute which contains the GFM reference
# - value: The resulting field representation
RSpec.shared_examples "img upload tags for status page" do
  it 'converts to html' do
    secret = '50b7a196557cf72a98e86a7ab4b1ac3b'
    filename = 'tanuki.png'
    markdown = "![tanuki](/uploads/#{secret}/#{filename})"
    object.send("#{field}=".to_sym, markdown)

    result_img_tag = Nokogiri::HTML(json[field]).css('img')[0]
    result_link_tag = result_img_tag.parent

    expected_source_path = Gitlab::StatusPage::Storage.upload_path(issue.iid, secret, filename)

    expect(result_img_tag['class']).to eq 'gl-image'
    expect(result_img_tag['src']).to eq expected_source_path
    expect(result_img_tag['alt']).to eq 'tanuki'
    expect(result_link_tag['href']).to eq expected_source_path
  end
end
