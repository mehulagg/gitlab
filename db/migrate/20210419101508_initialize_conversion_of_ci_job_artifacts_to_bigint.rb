# frozen_string_literal: true

class InitializeConversionOfCiJobArtifactsToBigint < Gitlab::Database::IntegerToBigintMigration
  def conversion
    IntegerToBigintConversion.new(:ci_job_artifacts, %i(id job_id))
  end
end
