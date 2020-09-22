# frozen_string_literal: true

module ShowInheritedLabelsChecker
  extend ActiveSupport::Concern

  private

  def show_inherited_labels?(options)
    Feature.enabled?(:show_inherited_labels, @project || @group) || options[:include_ancestor_groups] # rubocop:disable Gitlab/ModuleWithInstanceVariables
  end
end
