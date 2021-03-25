# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EnvironmentSerializer do
  let(:user) { create(:user) }
  let(:project) { create(:project) }

  let(:json) do
    described_class
      .new(current_user: user, project: project)
      .represent(resource)
  end

  before do
    project.add_developer(user)
  end

  context 'when there is a single object provided' do
    let(:project) { create(:project, :repository) }
    let(:deployable) { create(:ci_build) }
    let(:deployment) do
      create(:deployment, :success,
                          deployable: deployable,
                          user: user,
                          project: project,
                          sha: project.commit.id)
    end

    let(:resource) { deployment.environment }

    before do
      create(:ci_build, :manual, name: 'manual1', pipeline: deployable.pipeline)
    end

    it 'contains important elements of environment' do
      expect(json)
        .to include(:name, :external_url, :environment_path, :last_deployment)
    end

    it 'contains relevant information about last deployment' do
      last_deployment = json.fetch(:last_deployment)

      expect(last_deployment)
        .to include(:ref, :user, :commit, :deployable, :manual_actions)
    end
  end

  context 'when there is a collection of objects provided' do
    let(:project) { create(:project) }
    let(:resource) { create_list(:environment, 2) }

    it 'contains important elements of environment' do
      expect(json.first)
        .to include(:last_deployment, :name, :external_url)
    end

    it 'generates payload for collection' do
      expect(json).to be_an_instance_of Array
    end
  end

  context 'when representing environments within folders' do
    let(:serializer) do
      described_class
        .new(current_user: user, project: project)
        .within_folders
    end

    let(:resource) { Environment.all }

    subject { serializer.represent(resource) }

    context 'when there is a single environment' do
      before do
        create(:environment, name: 'staging')
      end

      it 'represents one standalone environment' do
        expect(subject.count).to eq 1
        expect(subject.first[:name]).to eq 'staging'
        expect(subject.first[:size]).to eq 1
        expect(subject.first[:latest][:name]).to eq 'staging'
      end
    end

    context 'when there are multiple environments in folder' do
      before do
        create(:environment, name: 'staging/my-review-1')
        create(:environment, name: 'staging/my-review-2')
      end

      it 'represents one item that is a folder' do
        expect(subject.count).to eq 1
        expect(subject.first[:name]).to eq 'staging'
        expect(subject.first[:size]).to eq 2
        expect(subject.first[:latest][:name]).to eq 'staging/my-review-2'
        expect(subject.first[:latest][:environment_type]).to eq 'staging'
      end
    end

    context 'when there are multiple folders and standalone environments' do
      before do
        create(:environment, name: 'staging/my-review-1')
        create(:environment, name: 'staging/my-review-2')
        create(:environment, name: 'production/my-review-3')
        create(:environment, name: 'testing')
      end

      it 'represents multiple items grouped within folders' do
        expect(subject.count).to eq 3

        expect(subject.first[:name]).to eq 'production'
        expect(subject.first[:size]).to eq 1
        expect(subject.first[:latest][:name]).to eq 'production/my-review-3'
        expect(subject.first[:latest][:environment_type]).to eq 'production'
        expect(subject.second[:name]).to eq 'staging'
        expect(subject.second[:size]).to eq 2
        expect(subject.second[:latest][:name]).to eq 'staging/my-review-2'
        expect(subject.second[:latest][:environment_type]).to eq 'staging'
        expect(subject.third[:name]).to eq 'testing'
        expect(subject.third[:size]).to eq 1
        expect(subject.third[:latest][:name]).to eq 'testing'
        expect(subject.third[:latest][:environment_type]).to be_nil
      end
    end
  end

  context 'when used with pagination' do
    let(:request) { double(url: "#{Gitlab.config.gitlab.url}:8080/api/v4/projects?#{query.to_query}", query_parameters: query) }
    let(:response) { spy('response') }
    let(:resource) { Environment.all }
    let(:query) { { page: 1, per_page: 2 } }

    let(:serializer) do
      described_class
        .new(current_user: user, project: project)
        .with_pagination(request, response)
    end

    subject { serializer.represent(resource) }

    it 'creates a paginated serializer' do
      expect(serializer).to be_paginated
    end

    context 'when resource is paginatable relation' do
      context 'when there is a single environment object in relation' do
        before do
          create(:environment)
        end

        it 'serializes environments' do
          expect(subject.first).to have_key :id
        end
      end

      context 'when multiple environment objects are serialized' do
        before do
          create_list(:environment, 3)
        end

        it 'serializes appropriate number of objects' do
          expect(subject.count).to be 2
        end

        it 'appends relevant headers' do
          expect(response).to receive(:[]=).with('X-Total', '3')
          expect(response).to receive(:[]=).with('X-Total-Pages', '2')
          expect(response).to receive(:[]=).with('X-Per-Page', '2')

          subject
        end
      end

      context 'when grouping environments within folders' do
        let(:serializer) do
          described_class
            .new(current_user: user, project: project)
            .with_pagination(request, response)
            .within_folders
        end

        before do
          create(:environment, name: 'staging/review-1')
          create(:environment, name: 'staging/review-2')
          create(:environment, name: 'production/deploy-3')
          create(:environment, name: 'testing')
        end

        it 'paginates grouped items including ordering' do
          expect(subject.count).to eq 2
          expect(subject.first[:name]).to eq 'production'
          expect(subject.second[:name]).to eq 'staging'
        end

        it 'appends correct total page count header' do
          expect(subject).not_to be_empty
          expect(response).to have_received(:[]=).with('X-Total', '3')
        end

        it 'appends correct page count headers' do
          expect(subject).not_to be_empty
          expect(response).to have_received(:[]=).with('X-Total-Pages', '2')
          expect(response).to have_received(:[]=).with('X-Per-Page', '2')
        end
      end
    end
  end

  describe 'avoid N+1 queries', :request_store do
    def expect_no_nplusone_queries(allow_list: [])
      require 'prosopite'

      Prosopite.raise = true
      Prosopite.allow_list = allow_list
      Prosopite.scan

      yield

      Prosopite.finish
    end

    let_it_be(:project) { create(:project, :repository) }

    it 'avoids more queries' do
      create_record
      control = ActiveRecord::QueryRecorder.new { serialize }

      p control.count, control.cached_count

      create_record

      control = ActiveRecord::QueryRecorder.new { serialize }

      p control.count, control.cached_count

      expect { serialize }.not_to exceed_all_query_limit(control)

      allow_list = %w[
        find_platform_kubernetes_with_cte
        find_instance_cluster_platform_kubernetes
        protected_environment_by_name
      ]

      expect_no_nplusone_queries(allow_list: allow_list) do
        serialize
      end
    end

    def create_record
      environment = create(:environment, project: project)

      create_deployment(environment, :success) # last_deployment
      create_deployment(environment, :running) # upcoming_deployment
    end

    def create_deployment(environment, status)
      pipeline = create(:ci_pipeline, status, project: project)
      deployable = create(:ci_build, status, project: project, pipeline: pipeline)

      create(:deployment, status, project: project, environment: environment, deployable: deployable)
    end

    def serialize
      described_class
        .new(current_user: user, project: project)
        .represent(Environment.all)
    end
  end
end
