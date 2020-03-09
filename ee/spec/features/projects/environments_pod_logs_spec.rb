# frozen_string_literal: true

require 'spec_helper'

describe 'Environment > Pod Logs', :js do
  include KubernetesHelpers

  SCROLL_DISTANCE = 400

  let(:pod_names) { %w(kube-pod) }
  let(:pod_name) { pod_names.first }
  let(:project) { create(:project, :repository) }
  let(:environment) { create(:environment, project: project) }
  let(:service) { create(:cluster_platform_kubernetes, :configured) }

  before do
    create(:cluster, :provided_by_gcp, environment_scope: '*', projects: [project])
    create(:deployment, :success, environment: environment)

    stub_kubeclient_pods(environment.deployment_namespace)
    stub_kubeclient_logs(pod_name, environment.deployment_namespace, container: 'container-0')

    sign_in(project.owner)
  end

  it "shows environments in dropdown" do
    create(:environment, project: project)

    visit project_logs_path(environment.project, environment_name: environment.name, pod_name: pod_name)

    wait_for_requests

    page.within('.js-environments-dropdown') do
      toggle = find(".dropdown-menu-toggle:not([disabled])")

      expect(toggle).to have_content(environment.name)

      toggle.click

      dropdown_items = find(".dropdown-menu").all(".dropdown-item")
      expect(dropdown_items.first).to have_content(environment.name)
      expect(dropdown_items.size).to eq(2)
    end
  end

  context 'with logs', :use_clean_rails_memory_store_caching do
    it "shows pod logs", :sidekiq_might_not_need_inline do
      visit project_logs_path(environment.project, environment_name: environment.name, pod_name: pod_name)

      wait_for_requests

      page.within('.js-pods-dropdown') do
        find(".dropdown-menu-toggle:not([disabled])").click

        dropdown_items = find(".dropdown-menu").all(".dropdown-item")
        expect(dropdown_items.size).to eq(1)

        dropdown_items.each_with_index do |item, i|
          expect(item.text).to eq(pod_names[i])
        end
      end
      expect(page).to have_content("Dec 13 14:04:22.123Z | Log 1 Dec 13 14:04:23.123Z | Log 2 Dec 13 14:04:24.123Z | Log 3")
    end
  end

  context 'with perf bar enabled' do
    before do
      allow(Gitlab::PerformanceBar).to receive(:enabled_for_request?).and_return(true)
    end

    it 'log header sticks to top' do
      load_and_scroll_down

      expect(log_header_top).to eq(navbar_height + perf_bar_height)
    end
  end

  context 'with perf bar disabled' do
    it 'log header sticks to top' do
      load_and_scroll_down

      expect(log_header_top).to eq(navbar_height)
    end
  end

  def load_and_scroll_down
    visit project_logs_path(environment.project, environment_name: environment.name, pod_name: pod_name)

    wait_for_requests

    scroll_down_build_log
  end

  def scroll_down_build_log
    page.execute_script("$('.js-build-output').height('200vh')")
    page.execute_script("window.scrollTo(0, #{SCROLL_DISTANCE})")
  end

  def perf_bar_height
    page.evaluate_script("$('#js-peek').height()").to_i
  end

  def navbar_height
    page.evaluate_script("$('.js-navbar').height()").to_i
  end

  def log_header_top
    page.evaluate_script("$('.js-top-bar').offset().top") - SCROLL_DISTANCE
  end
end
