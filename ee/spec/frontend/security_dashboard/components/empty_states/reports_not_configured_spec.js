import { shallowMount } from '@vue/test-utils';
import ReportsNotConfigured from 'ee/security_dashboard/components/empty_states/reports_not_configured.vue';

describe('reports not configured empty state', () => {
  let wrapper;
  const helpPath = '/help';
  const emptyStateSvgPath = '/placeholder.svg';
  const securityConfigurationPath = '/configuration';

  const createComponent = () => {
    wrapper = shallowMount(ReportsNotConfigured, {
      provide: {
        emptyStateSvgPath,
        securityConfigurationPath,
      },
      propsData: { helpPath },
    });
  };

  beforeEach(() => {
    createComponent();
  });

  it('matches snapshot', () => {
    expect(wrapper.html()).toMatchSnapshot();
  });
});
