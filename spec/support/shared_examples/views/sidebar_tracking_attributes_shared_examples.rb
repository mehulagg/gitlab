# frozen_string_literal: true

RSpec.shared_examples 'includes snowplow attributes' do |track_event, track_label, track_property|
  specify do
    allow(Rails.env).to receive(:production?).and_return(true)
    allow(Gitlab::CurrentSettings).to receive(:snowplow_enabled?).and_return(true)

    render

    expect(rendered).to have_css(".nav-sidebar[data-track-event=\"#{track_event}\"][data-track-label=\"#{track_label}\"][data-track-property=\"#{track_property}\"]")
  end
end
