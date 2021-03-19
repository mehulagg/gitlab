import { GlLoadingIcon } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import DashboardNotConfigured from 'ee/security_dashboard/components/empty_states/instance_dashboard_not_configured.vue';
import VulnerabilityChart from 'ee/security_dashboard/components/first_class_vulnerability_chart.vue';
import VulnerabilitySeverities from 'ee/security_dashboard/components/first_class_vulnerability_severities.vue';
import InstanceSecurityCharts from 'ee/security_dashboard/components/instance_security_charts.vue';
import SecurityChartsLayout from 'ee/security_dashboard/components/security_charts_layout.vue';
import vulnerabilityGradesQuery from 'ee/security_dashboard/graphql/queries/instance_vulnerability_grades.query.graphql';
import vulnerabilityHistoryQuery from 'ee/security_dashboard/graphql/queries/instance_vulnerability_history.query.graphql';

jest.mock(
  'ee/security_dashboard/graphql/queries/instance_vulnerability_grades.query.graphql',
  () => ({
    mockGrades: true,
  }),
);
jest.mock(
  'ee/security_dashboard/graphql/queries/instance_vulnerability_history.query.graphql',
  () => ({
    mockHistory: true,
  }),
);

describe('Instance Security Charts component', () => {
  let wrapper;

  const findSecurityChartsLayoutComponent = () => wrapper.find(SecurityChartsLayout);
  const findLoadingIcon = () => wrapper.find(GlLoadingIcon);
  const findVulnerabilityChart = () => wrapper.find(VulnerabilityChart);
  const findVulnerabilitySeverities = () => wrapper.find(VulnerabilitySeverities);
  const findDashboardNotConfigured = () => wrapper.find(DashboardNotConfigured);

  const createWrapper = ({ loading = false } = {}) => {
    wrapper = shallowMount(InstanceSecurityCharts, {
      mocks: {
        $apollo: {
          queries: {
            projects: {
              loading,
            },
          },
        },
      },
      stubs: {
        SecurityChartsLayout,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  it('renders the loading page', () => {
    createWrapper({ loading: true });

    const securityChartsLayout = findSecurityChartsLayoutComponent();
    const dashboardNotConfigured = findDashboardNotConfigured();
    const loadingIcon = findLoadingIcon();
    const vulnerabilityChart = findVulnerabilityChart();
    const vulnerabilitySeverities = findVulnerabilitySeverities();

    expect(securityChartsLayout.exists()).toBe(true);
    expect(dashboardNotConfigured.exists()).toBe(false);
    expect(loadingIcon.exists()).toBe(true);
    expect(vulnerabilityChart.exists()).toBe(false);
    expect(vulnerabilitySeverities.exists()).toBe(false);
  });

  it('renders the empty state', () => {
    createWrapper();

    const securityChartsLayout = findSecurityChartsLayoutComponent();
    const dashboardNotConfigured = findDashboardNotConfigured();
    const loadingIcon = findLoadingIcon();
    const vulnerabilityChart = findVulnerabilityChart();
    const vulnerabilitySeverities = findVulnerabilitySeverities();

    expect(securityChartsLayout.exists()).toBe(true);
    expect(dashboardNotConfigured.exists()).toBe(true);
    expect(loadingIcon.exists()).toBe(false);
    expect(vulnerabilityChart.exists()).toBe(false);
    expect(vulnerabilitySeverities.exists()).toBe(false);
  });

  it('renders the default page', async () => {
    createWrapper();
    wrapper.setData({ projects: [{ name: 'project1' }] });
    await wrapper.vm.$nextTick();

    const securityChartsLayout = findSecurityChartsLayoutComponent();
    const dashboardNotConfigured = findDashboardNotConfigured();
    const loadingIcon = findLoadingIcon();
    const vulnerabilityChart = findVulnerabilityChart();
    const vulnerabilitySeverities = findVulnerabilitySeverities();

    expect(securityChartsLayout.exists()).toBe(true);
    expect(dashboardNotConfigured.exists()).toBe(false);
    expect(loadingIcon.exists()).toBe(false);
    expect(vulnerabilityChart.props()).toEqual({ query: vulnerabilityHistoryQuery });
    expect(vulnerabilitySeverities.exists()).toBe(true);
    expect(vulnerabilitySeverities.props()).toEqual({
      query: vulnerabilityGradesQuery,
      groupFullPath: undefined,
      helpPagePath: '',
    });
  });
});
