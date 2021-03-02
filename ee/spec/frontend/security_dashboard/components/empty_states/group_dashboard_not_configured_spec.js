import { GlEmptyState, GlButton } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import DashboardNotConfigured from 'ee/security_dashboard/components/empty_states/group_dashboard_not_configured.vue';

describe('first class group security dashboard empty state', () => {
  let wrapper;
  const dashboardDocumentation = '/path/to/dashboard/documentation';
  const emptyStateSvgPath = '/placeholder.svg';

  const createWrapper = () =>
    shallowMount(DashboardNotConfigured, {
      provide: {
        dashboardDocumentation,
        emptyStateSvgPath,
      },
    });

  const findGlEmptyState = () => wrapper.find(GlEmptyState);
  const findButton = () => wrapper.find(GlButton);

  beforeEach(() => {
    wrapper = createWrapper();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('contains a GlEmptyState with the expected props', () => {
    const { title, description } = wrapper.vm.$options.i18n;

    expect(findGlEmptyState().props()).toMatchObject({
      title,
      description,
      svgPath: emptyStateSvgPath,
    });
  });

  it('contains a GlButton with the correct text and link', () => {
    expect(findButton().attributes('href')).toBe(dashboardDocumentation);
    expect(findButton().text()).toBe(wrapper.vm.$options.i18n.secondaryButtonText);
  });
});
