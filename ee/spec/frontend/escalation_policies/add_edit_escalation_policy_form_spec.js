import { GlLink } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import AddEscalationPolicyForm, {
  i18n,
} from 'ee/escalation_policies/components/add_edit_escalation_policy_form.vue';
import EscalationRule from 'ee/escalation_policies/components/escalation_rule.vue';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';

import mockPolicy from './mocks/mockPolicy.json';

describe('AddEscalationPolicyForm', () => {
  let wrapper;
  const projectPath = 'group/project';

  const createComponent = ({ props = {} } = {}) => {
    wrapper = extendedWrapper(
      shallowMount(AddEscalationPolicyForm, {
        propsData: {
          form: {
            name: mockPolicy.name,
            description: mockPolicy.description,
          },
          validationState: {
            name: true,
          },
          ...props,
        },
        provide: {
          projectPath,
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

  const findPolicyName = () => wrapper.findByTestId('escalation-policy-name');
  const findRules = () => wrapper.findAllComponents(EscalationRule);
  const findAddRuleLink = () => wrapper.findComponent(GlLink);

  it('renders form layout', () => {
    expect(wrapper.element).toMatchSnapshot();
  });

  describe('Schedule form validation', () => {
    it('should show feedback for an invalid name input validation state', async () => {
      createComponent({
        props: {
          validationState: { name: false },
        },
      });
      expect(findPolicyName().attributes('state')).toBeFalsy();
    });
  });

  describe('Escalation rules', () => {
    it('should render one default rule', () => {
      expect(findRules().length).toBe(1);
    });
    it('should contain a link to add escalation rules', () => {
      const link = findAddRuleLink();
      expect(link.exists()).toBe(true);
      expect(link.text()).toMatchInterpolatedText(`+ ${i18n.addRule}`);
    });

    it('should add an empty rule to the rules list on click', async () => {
      findAddRuleLink().vm.$emit('click');
      await wrapper.vm.$nextTick();
      expect(findRules().length).toBe(2);
    });
  });
});
