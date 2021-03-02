import { GlDropdownItem, GlTokenSelector, GlFormGroup, GlToggle } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import { cloneDeep, merge } from 'lodash';
import AddEditRotationForm from 'ee/oncall_schedules/components/rotations/components/add_edit_rotation_form.vue';
import { formEmptyState } from 'ee/oncall_schedules/components/rotations/components/add_edit_rotation_modal.vue';
import { LENGTH_ENUM } from 'ee/oncall_schedules/constants';
import { participants, getOncallSchedulesQueryResponse } from '../../mocks/apollo_mock';

const projectPath = 'group/project';
const schedule =
  getOncallSchedulesQueryResponse.data.project.incidentManagementOncallSchedules.nodes[0];

describe('AddEditRotationForm', () => {
  let wrapper;

  const createComponent = ({ data = {}, props = {} } = {}) => {
    wrapper = shallowMount(AddEditRotationForm, {
      data() {
        return {
          ...data,
        };
      },
      propsData: merge(
        {
          schedule,
          isLoading: false,
          validationState: {
            name: true,
            participants: false,
            startsAt: false,
            rotationLength: false,
          },
          participants,
          form: cloneDeep(formEmptyState),
        },
        props,
      ),
      provide: {
        projectPath,
      },
    });
  };

  afterEach(() => {
    if (wrapper) {
      wrapper.destroy();
    }
  });

  const findRotationLength = () => wrapper.find('[id="rotation-length"]');
  const findRotationStartTime = () => wrapper.find('[data-testid="rotation-start-time"]');
  const findRotationEndsContainer = () => wrapper.find('[data-testid="rotation-ends-on"]');
  const findEndDateToggle = () => wrapper.find(GlToggle);
  const findRotationEndTime = () => wrapper.find('[data-testid="rotation-end-time"]');
  const findUserSelector = () => wrapper.find(GlTokenSelector);
  const findRotationFormGroups = () => wrapper.findAllComponents(GlFormGroup);
  const findStartsOnTimeOptions = () => findRotationStartTime().findAllComponents(GlDropdownItem);
  const findEndsOnTimeOptions = () => findRotationEndTime().findAllComponents(GlDropdownItem);
  const findRestrictedToToggle = () => wrapper.find('[data-testid="restricted-to-toggle"]');
  const findRestrictedFromOptions = () =>
    wrapper.find('[data-testid="restricted-from"]').findAllComponents(GlDropdownItem);
  const findRestrictedToOptions = () =>
    wrapper.find('[data-testid="restricted-to"]').findAllComponents(GlDropdownItem);

  describe('Rotation form validation', () => {
    it.each`
      index | type                | validationState | value
      ${0}  | ${'name'}           | ${true}         | ${'true'}
      ${0}  | ${'name'}           | ${false}        | ${undefined}
      ${1}  | ${'participants'}   | ${true}         | ${'true'}
      ${1}  | ${'participants'}   | ${false}        | ${undefined}
      ${3}  | ${'startsAt'}       | ${true}         | ${'true'}
      ${3}  | ${'startsAt'}       | ${false}        | ${undefined}
      ${2}  | ${'rotationLength'} | ${true}         | ${'true'}
      ${2}  | ${'rotationLength'} | ${false}        | ${undefined}
    `(
      'form validation for $type returns $value when passed validate state of $validationState',
      ({ index, type, validationState, value }) => {
        createComponent({
          props: {
            validationState: {
              [type]: validationState,
            },
          },
        });

        const formGroup = findRotationFormGroups();
        expect(formGroup.at(index).attributes('state')).toBe(value);
      },
    );
  });

  describe('Rotation length and start time', () => {
    it('renders the rotation length value', async () => {
      createComponent();
      const rotationLength = findRotationLength();
      expect(rotationLength.exists()).toBe(true);
      expect(rotationLength.attributes('value')).toBe('1');
    });

    it('renders the rotation starts on datepicker', async () => {
      createComponent();
      const startsOn = findRotationStartTime();
      expect(startsOn.exists()).toBe(true);
      expect(startsOn.attributes('text')).toBe('00:00');
      expect(startsOn.attributes('headertext')).toBe('');
    });

    it('should emit an event with selected value on time selection', async () => {
      createComponent();
      findStartsOnTimeOptions().at(3).vm.$emit('click');
      const emittedEvent = wrapper.emitted('update-rotation-form');
      expect(emittedEvent).toHaveLength(1);
      expect(emittedEvent[0][0]).toEqual({ type: 'startsAt.time', value: 4 });
    });

    it('should add a checkmark to a selected start time', async () => {
      const time = 7;
      createComponent({
        props: {
          form: {
            startsAt: {
              time,
            },
            rotationLength: {
              length: 1,
              unit: LENGTH_ENUM.hours,
            },
          },
        },
      });
      expect(
        findStartsOnTimeOptions()
          .at(time - 1)
          .props('isChecked'),
      ).toBe(true);
    });
  });

  describe('Rotation end time', () => {
    it('toggles end time visibility', async () => {
      createComponent();
      const toggle = findEndDateToggle().vm;
      toggle.$emit('change', false);
      expect(findRotationEndsContainer().exists()).toBe(false);
      toggle.$emit('change', true);
      await wrapper.vm.$nextTick();
      expect(findRotationEndsContainer().exists()).toBe(true);
    });

    it('should emit an event with selected value on time selection', async () => {
      createComponent();
      findEndDateToggle().vm.$emit('change', true);
      await wrapper.vm.$nextTick();
      const option = 3;
      findEndsOnTimeOptions().at(option).vm.$emit('click');
      const emittedEvent = wrapper.emitted('update-rotation-form');
      expect(emittedEvent).toHaveLength(1);
      expect(emittedEvent[0][0]).toEqual({ type: 'endsOn.time', value: option + 1 });
    });

    it('should add a checkmark to a selected end time', async () => {
      const time = 5;
      createComponent({
        props: {
          form: {
            endsOn: {
              time,
            },
            startsAt: {
              time: 0,
            },
            rotationLength: {
              length: 1,
              unit: LENGTH_ENUM.hours,
            },
          },
        },
      });
      findEndDateToggle().vm.$emit('change', true);
      await wrapper.vm.$nextTick();
      expect(
        findEndsOnTimeOptions()
          .at(time - 1)
          .props('isChecked'),
      ).toBe(true);
    });
  });

  describe('Rotation restricted to time', () => {
    it('toggle state depends on isRestrictedToTime', async () => {
      createComponent();
      expect(findRestrictedToToggle().props('value')).toBe(false);

      createComponent({ props: { form: { ...formEmptyState, isRestrictedToTime: true } } });
      expect(findRestrictedToToggle().props('value')).toBe(true);
    });

    it('toggles end time visibility on', async () => {
      createComponent();
      const toggle = findRestrictedToToggle().vm;
      toggle.$emit('change', true);
      const emittedEvent = wrapper.emitted('update-rotation-form');
      expect(emittedEvent).toHaveLength(1);
      expect(emittedEvent[0][0]).toEqual({ type: 'isRestrictedToTime', value: true });
    });

    it('toggles end time visibility off', async () => {
      createComponent({ props: { form: { ...formEmptyState, isRestrictedToTime: true } } });
      const toggle = findRestrictedToToggle().vm;
      toggle.$emit('change', false);
      const emittedEvent = wrapper.emitted('update-rotation-form');
      expect(emittedEvent).toHaveLength(1);
      expect(emittedEvent[0][0]).toEqual({ type: 'isRestrictedToTime', value: false });
    });

    describe('when a rotation restriction is selected', () => {
      const timeFrom = 5;
      const timeTo = 22;

      it('should emit an event with selected value on restricted FROM time selection', async () => {
        createComponent({ props: { form: { ...formEmptyState, isRestrictedToTime: true } } });
        findRestrictedFromOptions().at(timeFrom).vm.$emit('click');
        findRestrictedToOptions().at(timeTo).vm.$emit('click');
        const emittedEvent = wrapper.emitted('update-rotation-form');
        expect(emittedEvent).toHaveLength(2);
        expect(emittedEvent[0][0]).toEqual({ type: 'restrictedTo.startTime', value: timeFrom + 1 });
        expect(emittedEvent[1][0]).toEqual({ type: 'restrictedTo.endTime', value: timeTo + 1 });
      });

      it('should add a checkmark to a selected restricted FROM time', async () => {
        createComponent({
          props: {
            form: {
              ...formEmptyState,
              isRestrictedToTime: true,
              restrictedTo: { startTime: timeFrom, endTime: timeTo },
            },
          },
        });
        expect(
          findRestrictedFromOptions()
            .at(timeFrom - 1)
            .props('isChecked'),
        ).toBe(true);
        expect(
          findRestrictedToOptions()
            .at(timeTo - 1)
            .props('isChecked'),
        ).toBe(true);
      });
    });
  });

  describe('filter participants', () => {
    beforeEach(() => {
      createComponent();
    });

    it('has user options that are populated via apollo', () => {
      expect(findUserSelector().props('dropdownItems')).toHaveLength(participants.length);
    });

    it('calls the API and sets dropdown items as request result', async () => {
      const tokenSelector = findUserSelector();

      tokenSelector.vm.$emit('focus');
      tokenSelector.vm.$emit('blur');
      tokenSelector.vm.$emit('focus');

      expect(tokenSelector.props('dropdownItems')).toMatchObject(participants);
      expect(tokenSelector.props('hideDropdownWithNoItems')).toBe(false);
    });

    it('emits `input` event with selected users', () => {
      findUserSelector().vm.$emit('input', participants);

      expect(findUserSelector().emitted().input[0][0]).toEqual(participants);
    });

    it('when text input is blurred the text input clears', async () => {
      const tokenSelector = findUserSelector();
      tokenSelector.vm.$emit('blur');

      expect(tokenSelector.props('hideDropdownWithNoItems')).toBe(false);
    });
  });
});
