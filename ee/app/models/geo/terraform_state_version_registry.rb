# frozen_string_literal: true

class Geo::TerraformStateVersionRegistry < Geo::BaseRegistry
  include Geo::ReplicableRegistry
  include ::Geo::VerifiableRegistry

  MODEL_CLASS = ::Terraform::StateVersion
  MODEL_FOREIGN_KEY = :terraform_state_version_id

  belongs_to :terraform_state_version, class_name: 'Terraform::StateVersion'
end
