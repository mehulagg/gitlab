class SitemapController < ApplicationController
  skip_before_action :authenticate_user!

  feature_category :metrics

  def show
    return render_404 unless Gitlab.com?

    respond_to do |format|
      format.xml do
        response = Sitemap::CreateService.new.execute

        if response.success?
          render inline: response.payload[:sitemap]
        else
          render inline: xml_error(response.message)
        end
      end
    end
  end

  private

  def xml_error(message)
    xml_builder = Builder::XmlMarkup.new(indent: 2)
    xml_builder.instruct!
    xml_builder.error message
  end
end
