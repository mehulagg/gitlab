import { GlEmptyState, GlButton, GlLink } from '@gitlab/ui';
import { mount } from '@vue/test-utils';
import ReportNotConfigured from 'ee/security_dashboard/components/instance/instance_report_not_configured.vue';

describe('first class instance security dashboard empty state', () => {
  let wrapper;
  const instanceDashboardSettingsPath = '/path/to/dashboard/settings';
  const dashboardDocumentation = '/path/to/dashboard/documentation';
  const emptyStateSvgPath = '/placeholder.svg';

  const createWrapper = () =>
    mount(ReportNotConfigured, {
      provide: {
        dashboardDocumentation,
        emptyStateSvgPath,
        instanceDashboardSettingsPath,
      },
    });

  const findGlEmptyState = () => wrapper.find(GlEmptyState);
  const findButton = () => wrapper.find(GlButton);
  const findLink = () => wrapper.find(GlLink);

  beforeEach(() => {
    wrapper = createWrapper();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('contains a GlEmptyState', () => {
    expect(findGlEmptyState().exists()).toBe(true);
    expect(findGlEmptyState().props('svgPath')).toBe(emptyStateSvgPath);
  });

  it('contains a GlLink with href attribute equal to dashboardDocumentation', () => {
    expect(findLink().attributes('href')).toBe(dashboardDocumentation);
  });

  it('contains a GlButton with a link to settings page', () => {
    expect(findButton().attributes('href')).toBe(instanceDashboardSettingsPath);
  });
});
