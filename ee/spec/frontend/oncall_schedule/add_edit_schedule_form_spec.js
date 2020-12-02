import { shallowMount } from '@vue/test-utils';
import { GlSearchBoxByType, GlDropdown, GlDropdownItem } from '@gitlab/ui';
import AddEditScheduleForm, {
  i18n,
} from 'ee/oncall_schedules/components/add_edit_schedule_form.vue';
import { getOncallSchedulesQueryResponse } from './mocks/apollo_mock';
import mockTimezones from './mocks/mockTimezones.json';

describe('AddEditScheduleForm', () => {
  let wrapper;
  const projectPath = 'group/project';
  const mutate = jest.fn();

  const createComponent = ({ props = {} } = {}) => {
    wrapper = shallowMount(AddEditScheduleForm, {
      propsData: {
        modalId: 'modalId',
        schedule:
          getOncallSchedulesQueryResponse.data.project.incidentManagementOncallSchedules.nodes[0],
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
      stubs: {
        GlFormGroup: false,
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

  it('renders modal layout', () => {
    expect(wrapper.element).toMatchSnapshot();
  });

  describe('Timezone select', () => {
    it('has options based on provided BE data', () => {
      expect(findDropdownOptions().length).toBe(mockTimezones.length);
    });

    it('formats each option', () => {
      findDropdownOptions().wrappers.forEach((option, index) => {
        const tz = mockTimezones[index];
        const expectedValue = `(UTC${tz.formatted_offset}) ${tz.abbr} ${tz.name}`;
        expect(option.text()).toBe(expectedValue);
      });
    });

    describe('timezones filtering', () => {
      it('should filter options based on search term', async () => {
        const searchTerm = 'Hawaii';
        findTimezoneSearchBox().vm.$emit('input', searchTerm);
        await wrapper.vm.$nextTick();
        const options = findDropdownOptions();
        expect(options.length).toBe(1);
        expect(options.at(0).text()).toContain(searchTerm);
      });

      it('should display no results item when there are no filter matches', async () => {
        const searchTerm = 'someUnexistentTZ';
        findTimezoneSearchBox().vm.$emit('input', searchTerm);
        await wrapper.vm.$nextTick();
        const options = findDropdownOptions();
        expect(options.length).toBe(1);
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

  describe('Schedule create', () => {});

  describe('Form validation', () => {
    describe('Timezone select', () => {
      it('has red border when nothing selected', () => {
        createComponent({ props: { schedule: null } });
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
