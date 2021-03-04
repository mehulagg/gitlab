# frozen_string_literal: true

class NullHypothesisExperiment < ApplicationExperiment # rubocop:disable Gitlab/NamespacedClass
  def flipper_id
    context.try(:project)&.flipper_id || super
  end
end
