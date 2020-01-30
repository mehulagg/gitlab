# frozen_string_literal: true

class ApplicationInstance
  extend ActiveModel::Naming
  include ::Vulnerable

  def all_pipelines
    ::Ci::Pipeline.all
  end

  def feature_available?(feature)
    License.feature_available?(feature)
  end
end
