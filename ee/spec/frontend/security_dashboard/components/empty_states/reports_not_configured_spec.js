import { GlEmptyState } from '@gitlab/ui';
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
  const findEmptyState = () => wrapper.find(GlEmptyState);

  beforeEach(() => {
    createComponent();
  });

  it('passes the correct data to the empty state component', () => {
    const { title, description, primaryButtonText, secondaryButtonText } = wrapper.vm.$options.i18n;

    expect(findEmptyState().props()).toMatchObject({
      title,
      description,
      primaryButtonText,
      secondaryButtonText,
      svgPath: emptyStateSvgPath,
      primaryButtonLink: securityConfigurationPath,
      secondaryButtonLink: helpPath,
    });
  });
});
