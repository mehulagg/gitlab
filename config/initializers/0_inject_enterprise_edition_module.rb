# frozen_string_literal: true

require 'active_support/inflector'

module InjectEnterpriseEditionModule
  def prepend_if_ee(constant = nil, with_descendants: false)
    return unless Gitlab.ee?

    ee_module = constant.constantize if constant
    ee_module ||= ::EE.const_get(name, false)

    prepend(ee_module)

    if with_descendants
      descendants.each { |descendant| descendant.prepend(ee_module) }
    end
  end

  def extend_if_ee(constant = nil)
    return unless Gitlab.ee?

    ee_module = constant.constantize if constant
    ee_module ||= ::EE.const_get(name, false)

    extend(ee_module)
  end

  def include_if_ee(constant = nil)
    return unless Gitlab.ee?

    ee_module = constant.constantize if constant
    ee_module ||= ::EE.const_get(name, false)

    include(ee_module)
  end
end

Module.prepend(InjectEnterpriseEditionModule)
