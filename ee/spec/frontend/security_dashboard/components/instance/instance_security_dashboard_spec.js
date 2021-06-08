import { GlLoadingIcon } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import DashboardNotConfigured from 'ee/security_dashboard/components/empty_states/instance_dashboard_not_configured.vue';
import VulnerabilitySeverities from 'ee/security_dashboard/components/first_class_vulnerability_severities.vue';
import InstanceSecurityDashboard from 'ee/security_dashboard/components/instance/instance_security_dashboard.vue';
import SecurityDashboardLayout from 'ee/security_dashboard/components/shared/security_dashboard_layout.vue';
import VulnerabilitiesOverTimeChart from 'ee/security_dashboard/components/shared/vulnerabilities_over_time_chart.vue';
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

describe('Instance Security Dashboard component', () => {
  let wrapper;

  const findSecurityChartsLayoutComponent = () => wrapper.find(SecurityDashboardLayout);
  const findLoadingIcon = () => wrapper.find(GlLoadingIcon);
  const findVulnerabilitiesOverTimeChart = () => wrapper.find(VulnerabilitiesOverTimeChart);
  const findVulnerabilitySeverities = () => wrapper.find(VulnerabilitySeverities);
  const findDashboardNotConfigured = () => wrapper.find(DashboardNotConfigured);

  const createWrapper = ({ loading = false } = {}) => {
    wrapper = shallowMount(InstanceSecurityDashboard, {
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
        SecurityDashboardLayout,
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
    const vulnerabilitiesOverTimeChart = findVulnerabilitiesOverTimeChart();
    const vulnerabilitySeverities = findVulnerabilitySeverities();

    expect(securityChartsLayout.exists()).toBe(true);
    expect(dashboardNotConfigured.exists()).toBe(false);
    expect(loadingIcon.exists()).toBe(true);
    expect(vulnerabilitiesOverTimeChart.exists()).toBe(false);
    expect(vulnerabilitySeverities.exists()).toBe(false);
  });

  it('renders the empty state', () => {
    createWrapper();

    const securityChartsLayout = findSecurityChartsLayoutComponent();
    const dashboardNotConfigured = findDashboardNotConfigured();
    const loadingIcon = findLoadingIcon();
    const vulnerabilitiesOverTimeChart = findVulnerabilitiesOverTimeChart();
    const vulnerabilitySeverities = findVulnerabilitySeverities();

    expect(securityChartsLayout.exists()).toBe(true);
    expect(dashboardNotConfigured.exists()).toBe(true);
    expect(loadingIcon.exists()).toBe(false);
    expect(vulnerabilitiesOverTimeChart.exists()).toBe(false);
    expect(vulnerabilitySeverities.exists()).toBe(false);
  });

  it('renders the default page', async () => {
    createWrapper();
    wrapper.setData({ projects: [{ name: 'project1' }] });
    await wrapper.vm.$nextTick();

    const securityChartsLayout = findSecurityChartsLayoutComponent();
    const dashboardNotConfigured = findDashboardNotConfigured();
    const loadingIcon = findLoadingIcon();
    const vulnerabilitiesOverTimeChart = findVulnerabilitiesOverTimeChart();
    const vulnerabilitySeverities = findVulnerabilitySeverities();

    expect(securityChartsLayout.exists()).toBe(true);
    expect(dashboardNotConfigured.exists()).toBe(false);
    expect(loadingIcon.exists()).toBe(false);
    expect(vulnerabilitiesOverTimeChart.props()).toEqual({ query: vulnerabilityHistoryQuery });
    expect(vulnerabilitySeverities.exists()).toBe(true);
    expect(vulnerabilitySeverities.props()).toEqual({
      query: vulnerabilityGradesQuery,
      groupFullPath: undefined,
      helpPagePath: '',
    });
  });
});
