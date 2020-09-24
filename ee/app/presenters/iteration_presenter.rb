# frozen_string_literal: true

class IterationPresenter < Gitlab::View::Presenter::Delegated
  presents :iteration

  def iteration_path
    url_builder.build(iteration, only_path: true)
  end

  def iteration_url
    url_builder.build(iteration)
  end

  def scoped_iteration_path(parent:)
    return unless parent[:parent_object]&.is_a?(Project)

    url_builder.inherited_iteration_path(parent[:parent_object], iteration)
  end

  def scoped_iteration_url(parent:)
    return unless parent[:parent_object]&.is_a?(Project)

    url_builder.inherited_iteration_url(parent[:parent_object], iteration)
  end
end
