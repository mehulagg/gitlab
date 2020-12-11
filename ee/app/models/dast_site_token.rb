# frozen_string_literal: true

class DastSiteToken < ApplicationRecord
  belongs_to :project

  validates :project_id, presence: true
  validates :token, length: { maximum: 255 }, presence: true
  validates :url, length: { maximum: 255 }, presence: true, public_url: true

  def dast_site
    DastSite.find_by(project_id: project.id, url: url)
  end
end
