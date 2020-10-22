import { mount } from '@vue/test-utils';
import { GlEmptyState, GlButton } from '@gitlab/ui';
import DashboardHasNoVulnerabilities from 'ee/security_dashboard/components/empty_states/dashboard_has_no_vulnerabilities.vue';

describe('dashboard has no vulnerabilities empty state', () => {
  let wrapper;
  const emptyStateSvgPath = '/placeholder.svg';
  const dashboardDocumentation = '/path/to/dashboard/documentation';

  const createWrapper = () =>
    mount(DashboardHasNoVulnerabilities, {
      provide: {
        emptyStateSvgPath,
        dashboardDocumentation,
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
      "While it's rare to have no vulnerabilities, it can happen. In any event, we ask that you double check your settings to make sure you've set up your dashboard correctly.",
    );
  });

  it('has the correct title', () => {
    expect(findGlEmptyState().text()).toContain('No vulnerabilities found');
  });
});
