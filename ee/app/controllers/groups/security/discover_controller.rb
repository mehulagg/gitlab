# frozen_string_literal: true

class Groups::Security::DiscoverController < Groups::ApplicationController
  layout 'group'

  def show
    render_404 unless helpers.show_discover_group_security?(@group)
  end
end
