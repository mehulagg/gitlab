import { GlDropdownItem, GlFormGroup, GlSprintf } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import { cloneDeep } from 'lodash';
import EscalationRule from 'ee/escalation_policies/components/escalation_rule.vue';
import { defaultEscalationRule, ACTIONS, ALERT_STATUSES } from 'ee/escalation_policies/constants';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';

const mockSchedules = [
  { id: 1, name: 'schedule1' },
  { id: 2, name: 'schedule2' },
  { id: 3, name: 'schedule3' },
];

describe('EscalationRule', () => {
  let wrapper;
  const createComponent = ({ props = {} } = {}) => {
    wrapper = extendedWrapper(
      shallowMount(EscalationRule, {
        propsData: {
          rule: cloneDeep(defaultEscalationRule),
          schedules: mockSchedules,
          index: 0,
          isValid: false,
          ...props,
        },
        stubs: {
          GlSprintf,
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

  const findStatusDropdown = () => wrapper.findByTestId('alert-status-dropdown');
  const findStatusDropdownOptions = () => findStatusDropdown().findAll(GlDropdownItem);

  const findActionDropdown = () => wrapper.findByTestId('action-dropdown');
  const findActionDropdownOptions = () => findActionDropdown().findAll(GlDropdownItem);

  const findSchedulesDropdown = () => wrapper.findByTestId('schedules-dropdown');
  const findSchedulesDropdownOptions = () => findSchedulesDropdown().findAll(GlDropdownItem);

  const findFormGroup = () => wrapper.findComponent(GlFormGroup);

  describe('Status dropdown', () => {
    it('should have correct alert status options', () => {
      expect(findStatusDropdownOptions().wrappers.map((w) => w.text())).toStrictEqual(
        Object.values(ALERT_STATUSES),
      );
    });

    it('should have default status selected', async () => {
      expect(findStatusDropdownOptions().at(0).props('isChecked')).toBe(true);
    });
  });

  describe('Actions dropdown', () => {
    it('should have correct action options', () => {
      expect(findActionDropdownOptions().wrappers.map((w) => w.text())).toStrictEqual(
        Object.values(ACTIONS),
      );
    });

    it('should have default action selected', async () => {
      expect(findActionDropdownOptions().at(0).props('isChecked')).toBe(true);
    });
  });

  describe('Schedules dropdown', () => {
    it('should have correct schedules options', () => {
      expect(findSchedulesDropdownOptions().wrappers.map((w) => w.text())).toStrictEqual(
        mockSchedules.map(({ name }) => name),
      );
    });
  });

  describe('Validation', () => {
    it.each`
      isValid  | state
      ${true}  | ${'true'}
      ${false} | ${undefined}
    `('when $isValid sets from group state to $state', ({ isValid, state }) => {
      createComponent({
        props: {
          isValid,
        },
      });
      expect(findFormGroup().attributes('state')).toBe(state);
    });
  });
});
