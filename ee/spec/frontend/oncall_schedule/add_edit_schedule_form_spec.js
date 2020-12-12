import { shallowMount } from '@vue/test-utils';
import {
  GlSearchBoxByType,
  GlDropdown,
  GlDropdownItem,
  GlFormInput,
  GlFormGroup,
} from '@gitlab/ui';
import AddEditScheduleForm, {
  i18n,
} from 'ee/oncall_schedules/components/add_edit_schedule_form.vue';
import { getOncallSchedulesQueryResponse } from './mocks/apollo_mock';
import mockTimezones from './mocks/mockTimezones.json';

describe('AddEditScheduleForm', () => {
  let wrapper;
  const projectPath = 'group/project';
  const mutate = jest.fn();
  const mockSchedule =
    getOncallSchedulesQueryResponse.data.project.incidentManagementOncallSchedules.nodes[0];

  const createComponent = ({ props = {} } = {}) => {
    wrapper = shallowMount(AddEditScheduleForm, {
      propsData: {
        modalId: 'modalId',
        form: {
          name: mockSchedule.name,
          description: mockSchedule.description,
          timezone: mockTimezones[0],
        },
        schedule: mockSchedule,
        ...props,
      },
      provide: {
        projectPath,
        timezones: mockTimezones,
      },
      mocks: {
        $apollo: {
          mutate,
        },
      },
    });
  };

  beforeEach(() => {
    createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  const findTimezoneDropdown = () => wrapper.find(GlDropdown);
  const findDropdownOptions = () => wrapper.findAll(GlDropdownItem);
  const findTimezoneSearchBox = () => wrapper.find(GlSearchBoxByType);
  const findScheduleNameName = () => wrapper.find(GlFormInput);
  const findInvalidFeedbackMessageByIndex = index =>
    wrapper
      .findAll(GlFormGroup)
      .at(index)
      .attributes('invalid-feedback');

  it('renders modal layout', () => {
    expect(wrapper.element).toMatchSnapshot();
  });

  describe('Schedule form validation', () => {
    it('should show feedback for an invalid name onBlur', async () => {
      await findScheduleNameName().vm.$emit('blur');
      expect(findInvalidFeedbackMessageByIndex(0)).toBe(i18n.fields.name.validation.empty);
    });
  });

  describe('Timezone select', () => {
    it('has options based on provided BE data', () => {
      expect(findDropdownOptions()).toHaveLength(mockTimezones.length);
    });

    it('formats each option', () => {
      findDropdownOptions().wrappers.forEach((option, index) => {
        const tz = mockTimezones[index];
        const expectedValue = `(UTC ${tz.formatted_offset}) ${tz.abbr} ${tz.name}`;
        expect(option.text()).toBe(expectedValue);
      });
    });

    describe('timezones filtering', () => {
      it('should filter options based on search term', async () => {
        const searchTerm = 'Hawaii';
        findTimezoneSearchBox().vm.$emit('input', searchTerm);
        await wrapper.vm.$nextTick();
        const options = findDropdownOptions();
        expect(options).toHaveLength(1);
        expect(options.at(0).text()).toContain(searchTerm);
      });

      it('should display no results item when there are no filter matches', async () => {
        const searchTerm = 'someUnexistentTZ';
        findTimezoneSearchBox().vm.$emit('input', searchTerm);
        await wrapper.vm.$nextTick();
        const options = findDropdownOptions();
        expect(options).toHaveLength(1);
        expect(options.at(0).text()).toContain(i18n.noResults);
      });
    });

    it('should add a checkmark to the selected option', async () => {
      const selectedTZOption = findDropdownOptions().at(0);
      selectedTZOption.vm.$emit('click');
      await wrapper.vm.$nextTick();
      expect(selectedTZOption.attributes('ischecked')).toBe('true');
    });
  });

  describe('Form validation', () => {
    describe('Timezone select', () => {
      it('has red border and offers validation feedback when nothing selected', async () => {
        createComponent({
          props: {
            schedule: null,
            form: { timezone: '' },
          },
        });
        await findTimezoneDropdown().vm.$emit('show');
        await findTimezoneDropdown().vm.$emit('hide');
        await wrapper.vm.$nextTick();
        expect(findInvalidFeedbackMessageByIndex(2)).toBe(i18n.fields.timezone.validation.empty);
        expect(findTimezoneDropdown().classes()).toContain('invalid-dropdown');
      });

      it("doesn't have a red border when there is selected option", async () => {
        findDropdownOptions()
          .at(1)
          .vm.$emit('click');
        await wrapper.vm.$nextTick();
        expect(findTimezoneDropdown().classes()).not.toContain('invalid-dropdown');
      });
    });
  });
});
