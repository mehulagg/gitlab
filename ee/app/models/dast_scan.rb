class DastScan < ApplicationRecord
  belongs_to :project
  belongs_to :dast_site_profile
  belongs_to :dast_scanner_profile
end
