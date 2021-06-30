import { GlLoadingIcon, GlIcon, GlPopover, GlLink, GlButton } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import SidebarDatepicker from 'ee/epic/components/sidebar_items/sidebar_date_picker.vue';
import { TEST_HOST } from 'helpers/test_constants';
import DatePicker from '~/vue_shared/components/pikaday.vue';
import CollapsedCalendarIcon from '~/vue_shared/components/sidebar/collapsed_calendar_icon.vue';
import ToggleSidebar from '~/vue_shared/components/sidebar/toggle_sidebar.vue';
import { mockDatePickerProps } from '../../mock_data';

describe('SidebarDatePicker', () => {
  let originalGon;
  beforeAll(() => {
    originalGon = global.gon;
    global.gon = { gitlab_url: TEST_HOST };
  });

  afterAll(() => {
    global.gon = originalGon;
  });

  let wrapper;

  const findIconByName = (name) =>
    wrapper
      .findAll(GlIcon)
      .filter((w) => w.props().name === name)
      .at(0);
  const findEditButton = () => wrapper.find({ ref: 'editButton' });
  const findRemoveButton = () => wrapper.find({ ref: 'removeButton' });

  const createFakeEvent = () => ({ stopPropagation: jest.fn() });

  const startEditing = () => {
    const e = createFakeEvent();
    findEditButton().vm.$emit('click', e);
  };

  const createComponent = (props) => {
    wrapper = shallowMount(SidebarDatepicker, {
      propsData: {
        ...mockDatePickerProps,
        ...props,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  it('generates unique names for input if `fieldName` prop is not provided', () => {
    createComponent();

    const anotherWrapper = shallowMount(SidebarDatepicker, {
      propsData: mockDatePickerProps,
    });

    const firstInputName = wrapper.find('input').attributes('name');
    const otherInputName = anotherWrapper.find('input').attributes('name');
    expect(firstInputName).toContain('dateType_');
    expect(otherInputName).toContain('dateType_');
    expect(firstInputName).not.toEqual(otherInputName);
    anotherWrapper.destroy();
  });

  it('renders remove button when both `selectedDate` is defined and `canUpdate` is true', () => {
    createComponent({
      selectedDate: new Date(),
      dateFixed: new Date(),
      canUpdate: true,
    });

    expect(findRemoveButton().exists()).toBe(true);
  });

  describe('collapsed calendar icon', () => {
    it('receives full date string in words based on `selectedDate` prop value', () => {
      createComponent({
        selectedDate: new Date(2018, 0, 1),
      });

      expect(wrapper.find(CollapsedCalendarIcon).props('text')).toBe('Jan 1, 2018');
    });

    it('receives `None` when `selectedDateWords` is not defined', () => {
      createComponent();

      expect(wrapper.find(CollapsedCalendarIcon).props('text')).toBe('None');
    });
  });

  it('returns full date string in words based on `dateFixed` prop value', () => {
    createComponent({
      dateFixed: new Date(2018, 0, 1),
    });

    expect(wrapper.text()).toContain('Jan 1, 2018');
  });

  it('returns full date string in words when `dateFromMilestones` is defined', () => {
    createComponent({ dateFromMilestones: new Date(2018, 0, 1) });

    expect(wrapper.text()).toContain('Inherited: Jan 1, 2018');
  });

  it('returns `None` when `dateFromMilestones` is not defined', () => {
    createComponent();
    expect(wrapper.text()).toContain('Inherited: None');
  });

  it('popover has message and link', () => {
    createComponent();

    const message =
      'These dates affect how your epics appear in the roadmap. Dates from milestones come from the milestones assigned to issues in the epic. You can also set fixed dates or remove them entirely.';

    const popover = wrapper.find(GlPopover);
    const popoverLink = popover.find(GlLink);

    expect(popover.text()).toContain(message);
    expect(popoverLink.text()).toBe('More information');
    expect(popoverLink.attributes('href')).toContain(
      '/help/user/group/epics/index.md#start-date-and-due-date',
    );
  });

  it('popover has different message and link when date is invalid', () => {
    createComponent({ isDateInvalid: true, selectedDateIsFixed: false });

    const popover = wrapper.findAll(GlPopover).at(1);
    const popoverLink = popover.find(GlLink);

    expect(popover.text()).toContain('Selected date is invalid');
    expect(popoverLink.text()).toBe('How can I solve this?');
    expect(popoverLink.attributes('href')).toContain(
      '/help/user/group/epics/index.md#start-date-and-due-date',
    );
  });

  it('stops editing and emits `toggleDateType` event on component on `hidePicker` from date picker', () => {
    createComponent({ canUpdate: true });
    startEditing();

    return wrapper.vm
      .$nextTick()
      .then(() => {
        wrapper.find(DatePicker).vm.$emit('hidePicker');
        expect(wrapper.emitted().toggleDateType[0]).toStrictEqual([
          { dateTypeIsFixed: true, typeChangeOnEdit: true },
        ]);
      })
      .then(() => wrapper.vm.$nextTick())
      .then(() => {
        expect(wrapper.find(DatePicker).exists()).toBe(false);
      });
  });

  it('starts editing when clicked on edit button', () => {
    createComponent();
    expect(wrapper.find(DatePicker).exists()).toBe(false);

    const e = createFakeEvent();
    findEditButton().vm.$emit('click', e);

    return wrapper.vm.$nextTick().then(() => {
      expect(e.stopPropagation).toHaveBeenCalled();
      expect(wrapper.find(DatePicker).exists()).toBe(true);
    });
  });

  it('stops editing and emits `saveDate` when `newDateSelected` emitted by date picker', () => {
    const date = new Date();
    createComponent();
    startEditing();

    return wrapper.vm.$nextTick().then(() => {
      wrapper.find(DatePicker).vm.$emit('newDateSelected', date);
      expect(wrapper.emitted().saveDate).toStrictEqual([[date]]);
    });
  });

  it('emits `toggleDateType` event on component when input is clicked', () => {
    createComponent({ canUpdate: true });

    wrapper.find('input').trigger('click');

    return wrapper.vm.$nextTick(() => {
      expect(wrapper.emitted().toggleDateType).toStrictEqual([[{ dateTypeIsFixed: true }]]);
    });
  });

  it('emits `toggleCollapse` event when toggle-sidebar emits `toggle` event', () => {
    createComponent({ showToggleSidebar: true });
    wrapper.find(ToggleSidebar).vm.$emit('toggle');

    return wrapper.vm.$nextTick().then(() => {
      expect(wrapper.emitted().toggleCollapse).toBeDefined();
    });
  });

  it('renders help icon', () => {
    createComponent();

    expect(wrapper.find(GlIcon).attributes('arialabel')).toBe('Help');
  });

  it('renders edit button', () => {
    createComponent();

    expect(wrapper.find(GlButton).text()).toBe('Edit');
  });

  it('renders an abbreviation', () => {
    createComponent();

    expect(wrapper.find('abbr').attributes('title')).toBe(
      'Select an issue with milestone to set date',
    );
  });

  it('renders collapse button when `showToggleSidebar` prop is `true`', () => {
    createComponent({ showToggleSidebar: true });

    expect(wrapper.find(ToggleSidebar).exists()).toBe(true);
  });

  it('renders loading icon when `dateSaveInProgress` prop is true', () => {
    createComponent({ dateSaveInProgress: true });

    expect(wrapper.find(GlLoadingIcon).exists()).toBe(true);
  });

  it('renders date warning icon when `isDateInvalid` prop is `true`', () => {
    createComponent({ isDateInvalid: true, selectedDateIsFixed: false });
    const warningIcon = findIconByName('warning');

    expect(warningIcon.exists()).toBe(true);
    expect(warningIcon.attributes('tabindex')).toBe('0');
  });
});
