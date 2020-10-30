class SitemapController < ApplicationController
  skip_before_action :authenticate_user!

  feature_category :metrics

  def show
    respond_to do |format|
      format.xml do
        render inline: Gitlab::Sitemaps::Generator.execute
      end
    end
  end
end
