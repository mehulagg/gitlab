# frozen_string_literal: true

RSpec.shared_examples 'emoji shared examples' do
  it 'keeps whitespace intact' do
    doc = filter("This deserves a #{emoji_name}, big time.")

    expect(doc.to_html).to match(/^This deserves a <gl-emoji.+>, big time\.\z/)
  end

  it 'does not match emoji in a string' do
    doc = filter("'2a00:a4c0#{emoji_name}:1'")

    expect(doc.css('gl-emoji')).to be_empty
  end

  it 'ignores non existent/unsupported emoji' do
    exp = '<p>:foo:</p>'
    doc = filter(exp)

    expect(doc.to_html).to eq(exp)
  end

  it 'matches with adjacent text' do
    doc = filter("#{emoji_name.delete(':')} (#{emoji_name})")

    expect(doc.css('gl-emoji').size).to eq 1
  end
end
