import { GlSprintf } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import { cloneDeep } from 'lodash';
import EscalationPolicy from 'ee/escalation_policies/components/escalation_policy.vue';

import mockPolicy from './mocks/mockPolicy.json';

describe('EscalationPolicy', () => {
  let wrapper;
  const createComponent = () => {
    wrapper = shallowMount(EscalationPolicy, {
      propsData: {
        policy: cloneDeep(mockPolicy),
        index: 0,
      },
      stubs: {
        GlSprintf,
      },
    });
  };

  beforeEach(() => {
    createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('renders policy with rules', () => {
    expect(wrapper.element).toMatchSnapshot();
  });
});
