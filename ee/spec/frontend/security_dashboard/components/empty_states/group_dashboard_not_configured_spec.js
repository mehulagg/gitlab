import { mount } from '@vue/test-utils';
import { GlEmptyState, GlButton } from '@gitlab/ui';
import DashboardNotConfigured from 'ee/security_dashboard/components/empty_states/group_dashboard_not_configured.vue';

describe('first class group security dashboard empty state', () => {
  let wrapper;
  const dashboardDocumentation = '/path/to/dashboard/documentation';
  const emptyStateSvgPath = '/placeholder.svg';

  const createWrapper = () =>
    mount(DashboardNotConfigured, {
      provide: {
        dashboardDocumentation,
        emptyStateSvgPath,
      },
    });

  const findGlEmptyState = () => wrapper.find(GlEmptyState);
  const findButton = () => wrapper.find(GlButton);
  const findLink = () => wrapper.find('a');

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

  it('contains a GlButton', () => {
    expect(findButton().exists()).toBe(true);
  });

  it('has the correct message', () => {
    expect(findGlEmptyState().text()).toContain(
      'The security dashboard displays the latest security findings for projects you wish to monitor. Add projects to your group to view their vulnerabilities here.',
    );
  });

  it('has the correct title', () => {
    expect(findGlEmptyState().text()).toContain('Add projects to your group');
  });
});
