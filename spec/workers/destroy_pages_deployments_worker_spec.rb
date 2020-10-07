# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DestroyPagesDeploymentsWorker do
  subject(:worker) { described_class.new }

  let!(:deployment) { create(:pages_deployment) }
  let!(:another_deployment) { create(:pages_deployment) }

  it 'destroys the pages deployment' do
    expect do
      worker.perform(deployment.id)
    end.to change { PagesDeployment.count }.from(2).to(1)

    expect(PagesDeployment.find_by_id(deployment.id)).to be_nil
    expect(PagesDeployment.find_by_id(another_deployment.id)).to be
  end

  it 'can destroy multiple deployments' do
    deployments_to_destroy = create_list(:pages_deployment, 3)

    expect do
      worker.perform(deployments_to_destroy.map(&:id))
    end.to change { PagesDeployment.count }.by(-3)
  end

  it 'does not raise an exception if deployment is already removed' do
    deployment.destroy!

    expect do
      worker.perform(deployment.id)
    end.not_to change { PagesDeployment.count }.from(1)
  end
end
