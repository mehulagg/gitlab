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
    });

    wrapper.vm.$refs.createScheduleModal.hide = mockHideModal;
  }

  beforeEach(() => {
    mountComponent();
  });

  afterEach(() => {
    if (wrapper) {
      wrapper.destroy();
      wrapper = null;
    }
  });

  const findModal = () => wrapper.find(GlModal);
  const findDropdownOptions = () => wrapper.findAll(GlDropdownItem);
  const findTimezoneSearchBox = () => wrapper.find(GlSearchBoxByType);
  const findAlert = () => wrapper.find(GlAlert);
  const findNameInput = () => wrapper.find('[id="schedule-name"]');
  const findNameValidationErr = () => wrapper.find('[data-testid="name-validation-error"]');
  const findTimezoneDropdown = () => wrapper.find(GlDropdown);
  const findTimezoneValidationErr = () => wrapper.find('[data-testid="timezone-validation-error"]');

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
        expect(findDropdownOptions().length).toBe(1);
        expect(
          findDropdownOptions()
            .at(0)
            .text(),
        ).toContain(searchTerm);
      });

      it('should display no results item when there are no filter matches', async () => {
        const searchTerm = 'someUnexistentTZ';
        findTimezoneSearchBox().vm.$emit('input', searchTerm);
        await wrapper.vm.$nextTick();
        expect(findDropdownOptions().length).toBe(1);
        expect(
          findDropdownOptions()
            .at(0)
            .text(),
        ).toContain(i18n.noResults);
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
      expect(mockHideModal).not.toHaveBeenCalled();
      expect(findAlert().exists()).toBe(true);
      expect(findAlert().text()).toContain(error);
    });
  });

  describe('Form validation', () => {
    describe('Schedule name', () => {
      it('shows error message under the name field when it is empty', async () => {
        const input = findNameInput();
        input.vm.$emit('input', '');

        await wrapper.vm.$nextTick();
        expect(findNameValidationErr().text()).toBe(i18n.fields.name.validation.empty);
      });
    });

    describe('Timezone select', () => {
      it('shows error message under the timezone field and adds red border when timezone is NOT selected', () => {
        const dropdown = findTimezoneDropdown();
        expect(dropdown.classes()).toContain('invalid-dropdown');
        expect(findTimezoneValidationErr().text()).toBe(i18n.fields.timezone.validation.empty);
      });

      it("doesn't show error message and doesn't add red border when timezone is selected", async () => {
        const dropdown = findTimezoneDropdown();
        findDropdownOptions()
          .at(1)
          .vm.$emit('click');
        await wrapper.vm.$nextTick();
        expect(dropdown.classes()).not.toContain('invalid-dropdown');
        expect(findTimezoneValidationErr().exists()).toBe(false);
      });
    });
  });
});
