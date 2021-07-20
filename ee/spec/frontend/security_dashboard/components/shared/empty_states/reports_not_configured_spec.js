import { shallowMount } from '@vue/test-utils';
import ReportsNotConfigured from 'ee/security_dashboard/components/shared/empty_states/reports_not_configured.vue';

describe('reports not configured empty state', () => {
  let wrapper;
  const emptyStateSvgPath = '/placeholder.svg';
  const securityConfigurationPath = '/configuration';
  const securityDashboardHelpPath = '/help';

  const createComponent = () => {
    wrapper = shallowMount(ReportsNotConfigured, {
      provide: {
        emptyStateSvgPath,
        securityConfigurationPath,
        securityDashboardHelpPath,
      },
    });
  };

  beforeEach(() => {
    createComponent();
  });

  it('matches snapshot', () => {
    expect(wrapper.html()).toMatchSnapshot();
  });
});
