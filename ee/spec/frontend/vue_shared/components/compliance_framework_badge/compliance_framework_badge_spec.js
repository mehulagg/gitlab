import { GlBadge } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import ComplianceFrameworkBadge from 'ee/vue_shared/components/compliance_framework_badge/compliance_framework_badge.vue';

describe('ComplianceFrameworkBadge component', () => {
  let wrapper;
  const propsData = {
    color: '#009966',
    description: 'General Data Protection Regulation',
    name: 'GDPR',
  };

  beforeEach(() => {
    wrapper = shallowMount(ComplianceFrameworkBadge, {
      propsData,
      stubs: {
        GlBadge,
      },
    });
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('matches the snapshot', () => {
    expect(wrapper.element).toMatchSnapshot();
  });
});
