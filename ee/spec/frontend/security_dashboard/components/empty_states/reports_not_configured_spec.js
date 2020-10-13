import { shallowMount } from '@vue/test-utils';
import { GlEmptyState } from '@gitlab/ui';
import ReportsNotConfigured from 'ee/security_dashboard/components/empty_states/reports_not_configured.vue';

describe('reports not configured empty state', () => {
  let wrapper;
  const helpPath = '/help';
  const emptyStateSvgPath = '/placeholder.svg';

  const createComponent = () => {
    wrapper = shallowMount(ReportsNotConfigured, {
      provide: {
        emptyStateSvgPath,
      },
      propsData: { helpPath },
    });
  };
  const findEmptyState = () => wrapper.find(GlEmptyState);

  beforeEach(() => {
    createComponent();
  });

  it.each`
    prop                   | data
    ${'title'}             | ${'Monitor vulnerabilities in your code'}
    ${'svgPath'}           | ${emptyStateSvgPath}
    ${'description'}       | ${'The security dashboard displays the latest security report. Use it to find and fix vulnerabilities.'}
    ${'primaryButtonLink'} | ${helpPath}
    ${'primaryButtonText'} | ${'Learn more'}
  `('passes the correct data to the $prop prop', ({ prop, data }) => {
    expect(findEmptyState().props(prop)).toBe(data);
  });
});
