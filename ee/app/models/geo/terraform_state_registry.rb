# frozen_string_literal: true

class Geo::TerraformStateRegistry < Geo::BaseRegistry
  include Geo::ReplicableRegistry

  MODEL_CLASS = ::Terraform::State
  MODEL_FOREIGN_KEY = :terraform_state_id

  belongs_to :terraform_state, class_name: 'Terraform::State'
end
