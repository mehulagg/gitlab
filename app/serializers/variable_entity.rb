class VariableEntity < Grape::Entity
  prepend ::EE::VariableEntity

  expose :id
  expose :key
  expose :value

  expose :protected?, as: :protected
end
