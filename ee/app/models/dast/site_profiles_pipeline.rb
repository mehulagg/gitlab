# frozen_string_literal: true

module Dast
  class SiteProfilesPipeline < ApplicationRecord
    extend SuppressCompositePrimaryKeyWarning

    self.table_name = 'dast_site_profiles_pipelines'

    belongs_to :ci_pipeline, class_name: 'Ci::Pipeline', optional: false, inverse_of: :dast_site_profiles_pipeline
    belongs_to :dast_site_profile, class_name: 'DastSiteProfile', optional: false, inverse_of: :dast_site_profiles_pipelines
  end
end
