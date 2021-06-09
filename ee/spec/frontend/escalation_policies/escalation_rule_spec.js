import { GlDropdownItem, GlFormGroup, GlSprintf } from '@gitlab/ui';
import { cloneDeep } from 'lodash';
import EscalationRule, { i18n } from 'ee/escalation_policies/components/escalation_rule.vue';
import { DEFAULT_ESCALATION_RULE, ACTIONS, ALERT_STATUSES } from 'ee/escalation_policies/constants';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';

const mockSchedules = [
  { id: 1, name: 'schedule1' },
  { id: 2, name: 'schedule2' },
  { id: 3, name: 'schedule3' },
];

const emptyScheduleMsg = i18n.fields.rules.emptyScheduleValidationMsg;
const invalidTimeMsg = i18n.fields.rules.invalidTimeValidationMsg;

describe('EscalationRule', () => {
  let wrapper;
  const createComponent = ({ props = {} } = {}) => {
    wrapper = shallowMountExtended(EscalationRule, {
      propsData: {
        rule: cloneDeep(DEFAULT_ESCALATION_RULE),
        schedules: mockSchedules,
        schedulesLoading: false,
        index: 0,
        isValid: false,
        ...props,
      },
      stubs: {
        GlFormGroup,
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

  const findStatusDropdown = () => wrapper.findByTestId('alert-status-dropdown');
  const findStatusDropdownOptions = () => findStatusDropdown().findAll(GlDropdownItem);

  const findActionDropdown = () => wrapper.findByTestId('action-dropdown');
  const findActionDropdownOptions = () => findActionDropdown().findAll(GlDropdownItem);

  const findSchedulesDropdown = () => wrapper.findByTestId('schedules-dropdown');
  const findSchedulesDropdownOptions = () => findSchedulesDropdown().findAll(GlDropdownItem);

  const findFormGroup = () => wrapper.findComponent(GlFormGroup);

  const findNoSchedulesInfoIcon = () => wrapper.findByTestId('no-schedules-info-icon');

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

    it('should NOT disable the dropdown OR show the info icon when schedules are loaded and provided', () => {
      expect(findSchedulesDropdown().attributes('disabled')).toBeUndefined();
      expect(findNoSchedulesInfoIcon().exists()).toBe(false);
    });

    it('should disable the dropdown and show the info icon when no schedules provided', () => {
      createComponent({ props: { schedules: [], schedulesLoading: false } });
      expect(findSchedulesDropdown().attributes('disabled')).toBe('true');
      expect(findNoSchedulesInfoIcon().exists()).toBe(true);
    });
  });

  describe('Validation', () => {
    describe.each`
      validationState                                   | formState
      ${{ isTimeValid: true, isScheduleValid: true }}   | ${'true'}
      ${{ isTimeValid: false, isScheduleValid: true }}  | ${undefined}
      ${{ isTimeValid: true, isScheduleValid: false }}  | ${undefined}
      ${{ isTimeValid: false, isScheduleValid: false }} | ${undefined}
    `(`when`, ({ validationState, formState }) => {
      describe(`elapsed minutes control is ${
        validationState.isTimeValid ? 'valid' : 'invalid'
      } and schedule control is ${validationState.isScheduleValid ? 'valid' : 'invalid'}`, () => {
        beforeEach(() => {
          createComponent({
            props: {
              validationState,
            },
          });
        });

        it(`sets form group validation state to ${formState}`, () => {
          expect(findFormGroup().attributes('state')).toBe(formState);
        });

        it(`does ${
          validationState.isTimeValid ? 'not show' : 'show'
        } invalid time error message && does ${
          validationState.isScheduleValid ? 'not show' : 'show'
        } invalid schedule error message `, () => {
          if (validationState.isTimeValid) {
            expect(findFormGroup().text()).not.toContain(invalidTimeMsg);
          } else {
            expect(findFormGroup().text()).toContain(invalidTimeMsg);
          }
          if (validationState.isScheduleValid) {
            expect(findFormGroup().text()).not.toContain(emptyScheduleMsg);
          } else {
            expect(findFormGroup().text()).toContain(emptyScheduleMsg);
          }
        });
      });
    });
  });
});
