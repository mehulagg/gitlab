import { GlEmptyState } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import DashboardNotConfigured from 'ee/security_dashboard/components/empty_states/instance_dashboard_not_configured.vue';

describe('first class instance security dashboard empty state', () => {
  let wrapper;
  const instanceDashboardSettingsPath = '/path/to/dashboard/settings';
  const dashboardDocumentation = '/path/to/dashboard/documentation';
  const emptyStateSvgPath = '/placeholder.svg';

  const createWrapper = () =>
    shallowMount(DashboardNotConfigured, {
      provide: {
        dashboardDocumentation,
        emptyStateSvgPath,
        instanceDashboardSettingsPath,
      },
    });

  const findGlEmptyState = () => wrapper.find(GlEmptyState);

  beforeEach(() => {
    wrapper = createWrapper();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('contains a GlEmptyState with the expected props', () => {
    const { title, description, primaryButtonText, secondaryButtonText } = wrapper.vm.$options.i18n;

    expect(findGlEmptyState().props()).toMatchObject({
      title,
      svgPath: emptyStateSvgPath,
      description,
      primaryButtonText,
      secondaryButtonText,
      primaryButtonLink: instanceDashboardSettingsPath,
      secondaryButtonLink: dashboardDocumentation,
    });
  });
});
