# frozen_string_literal: true

module Ci
  class BuildTraceSectionName < ApplicationRecord
    extend Gitlab::Ci::Model

    belongs_to :project

    validates :name, :project, presence: true, allow_blank: false
    validates :name, uniqueness: { scope: :project_id }
  end
end
