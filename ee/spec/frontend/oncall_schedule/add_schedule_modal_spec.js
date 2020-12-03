import { shallowMount } from '@vue/test-utils';
import { GlSearchBoxByType, GlDropdown, GlDropdownItem, GlModal, GlAlert } from '@gitlab/ui';
import waitForPromises from 'helpers/wait_for_promises';
import AddScheduleModal, { i18n } from 'ee/oncall_schedules/components/add_schedule_modal.vue';
import mockTimezones from './mocks/mockTimezones.json';

describe('AddScheduleModal', () => {
  let wrapper;
  const projectPath = 'group/project';
  const mutate = jest.fn();
  const mockHideModal = jest.fn();

  function mountComponent() {
    wrapper = shallowMount(AddScheduleModal, {
      propsData: {
        modalId: 'modalId',
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

    wrapper.vm.$refs.createScheduleModal.hide = mockHideModal;
  }

  beforeEach(() => {
    mountComponent();
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  const findModal = () => wrapper.find(GlModal);
  const findAlert = () => wrapper.find(GlAlert);
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

  describe('Schedule create', () => {
    it('makes a request with form data to create a schedule', () => {
      mutate.mockResolvedValueOnce({});
      findModal().vm.$emit('primary', { preventDefault: jest.fn() });
      expect(mutate).toHaveBeenCalledWith({
        mutation: expect.any(Object),
        variables: { oncallScheduleCreateInput: expect.objectContaining({ projectPath }) },
      });
    });

    it('hides the modal on successful schedule creation', async () => {
      mutate.mockResolvedValueOnce({ data: { oncallScheduleCreate: { errors: [] } } });
      findModal().vm.$emit('primary', { preventDefault: jest.fn() });
      await waitForPromises();
      expect(mockHideModal).toHaveBeenCalled();
    });

    it("doesn't hide a modal and shows error alert on fail", async () => {
      const error = 'some error';
      mutate.mockResolvedValueOnce({ data: { oncallScheduleCreate: { errors: [error] } } });
      findModal().vm.$emit('primary', { preventDefault: jest.fn() });
      await waitForPromises();
      const alert = findAlert();
      expect(mockHideModal).not.toHaveBeenCalled();
      expect(alert.exists()).toBe(true);
      expect(alert.text()).toContain(error);
    });
  });

  describe('Form validation', () => {
    describe('Timezone select', () => {
      it('has red border when nothing selected', () => {
        expect(findTimezoneDropdown().classes()).toContain('invalid-dropdown');
      });

      it("doesn't have a red border when there is selected opeion", async () => {
        findDropdownOptions()
          .at(1)
          .vm.$emit('click');
        await wrapper.vm.$nextTick();
        expect(findTimezoneDropdown().classes()).not.toContain('invalid-dropdown');
      });
    });
  });
});
