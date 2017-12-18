module Ci
  class Variable < ActiveRecord::Base
    extend Gitlab::Ci::Model
    include HasVariable
    include Presentable
    prepend HasEnvironmentScope

    belongs_to :project

    validates :key, uniqueness: { scope: [:project_id, :environment_scope] }

    scope :unprotected, -> { where(protected: false) }
  end
end
