import { shallowMount } from '@vue/test-utils';
import { cloneDeep } from 'lodash';
import EscalationRule from 'ee/escalation_policies/components/escalation_rule.vue';
import { defaultEscalationRule } from 'ee/escalation_policies/constants';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';

describe('EscalationRule', () => {
  let wrapper;
  const createComponent = ({ props = {} } = {}) => {
    wrapper = extendedWrapper(
      shallowMount(EscalationRule, {
        propsData: {
          rule: cloneDeep(defaultEscalationRule),
          ...props,
        },
      }),
    );
  };

  beforeEach(() => {
    createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('renders default rule layout', () => {
    expect(wrapper.element).toMatchSnapshot();
  });
});
