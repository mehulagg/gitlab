import { GlDropdown, GlDropdownItem, GlLoadingIcon, GlTooltip } from '@gitlab/ui';
import { mount, shallowMount } from '@vue/test-utils';
import Vue from 'vue';
import Status from 'ee/sidebar/components/status/status.vue';
import { healthStatus, healthStatusTextMap } from 'ee/sidebar/constants';

const getStatusText = wrapper => wrapper.find('.value .text-plain').text();

const getTooltipText = wrapper => wrapper.find(GlTooltip).text();

const getEditButton = wrapper => wrapper.find({ ref: 'editButton' });

const getDropdownElement = wrapper => wrapper.find(GlDropdown);

const getRemoveStatusItem = wrapper => wrapper.find(GlDropdownItem);

describe('Status', () => {
  let wrapper;

  function shallowMountStatus(propsData) {
    wrapper = shallowMount(Status, {
      propsData,
    });
  }

  function mountStatus(propsData) {
    wrapper = mount(Status, {
      propsData,
    });
  }

  afterEach(() => {
    wrapper.destroy();
  });

  it('shows the text "Status"', () => {
    shallowMountStatus();
    expect(wrapper.find('.title').text()).toBe('Health status');
  });

  describe('loading icon', () => {
    it('is displayed when retrieving data', () => {
      const props = {
        isFetching: true,
      };

      shallowMountStatus(props);

      expect(wrapper.contains(GlLoadingIcon)).toBe(true);
    });

    it('is hidden when not retrieving data', () => {
      const props = {
        isFetching: false,
      };

      shallowMountStatus(props);

      expect(wrapper.contains(GlLoadingIcon)).toBe(false);
    });
  });

  describe('edit button', () => {
    it('is displayed when user can edit', () => {
      const props = {
        isEditable: true,
      };

      shallowMountStatus(props);

      expect(getEditButton(wrapper).exists()).toBe(true);
    });

    it('is hidden when user cannot edit', () => {
      const props = {
        isEditable: false,
      };

      shallowMountStatus(props);

      expect(getEditButton(wrapper).exists()).toBe(false);
    });
  });

  describe('remove status dropdown item', () => {
    it('is displayed when there is a status', () => {
      const props = {
        isEditable: true,
        status: healthStatus.AT_RISK,
      };

      shallowMountStatus(props);

      wrapper.vm.isDropdownShowing = true;

      wrapper.vm.$nextTick(() => {
        expect(getRemoveStatusItem(wrapper).exists()).toBe(true);
      });
    });

    it('emits an onDropdownClick event with argument null when clicked', () => {
      const props = {
        isEditable: true,
        status: healthStatus.AT_RISK,
      };

      shallowMountStatus(props);

      wrapper.vm.isDropdownShowing = true;

      wrapper.vm.$nextTick(() => {
        getRemoveStatusItem(wrapper).vm.$emit('click', { preventDefault: () => null });

        expect(wrapper.emitted().onDropdownClick[0]).toEqual([null]);
      });
    });
  });

  describe('status text', () => {
    describe('when no value is provided for status', () => {
      beforeEach(() => {
        const props = {
          status: '',
        };

        shallowMountStatus(props);
      });

      it('shows "None"', () => {
        expect(wrapper.find('.no-value').text()).toBe('None');
      });

      it('shows "Status" in the tooltip', () => {
        expect(getTooltipText(wrapper)).toBe('Health status');
      });
    });

    describe.each(Object.values(healthStatus))(`when "%s" is provided for status`, statusValue => {
      beforeEach(() => {
        const props = {
          status: statusValue,
        };

        shallowMountStatus(props);
      });

      it(`shows "${healthStatusTextMap[statusValue]}"`, () => {
        expect(getStatusText(wrapper)).toBe(healthStatusTextMap[statusValue]);
      });

      it(`shows "Status: ${healthStatusTextMap[statusValue]}" in the tooltip`, () => {
        expect(getTooltipText(wrapper)).toBe(`Health status: ${healthStatusTextMap[statusValue]}`);
      });
    });
  });

  describe('status dropdown', () => {
    it('is hidden by default', () => {
      const props = {
        isEditable: true,
      };

      mountStatus(props);

      const dropdown = wrapper.find('.dropdown');

      expect(dropdown.classes()).toContain('d-none');
    });

    describe('when hidden', () => {
      beforeEach(() => {
        const props = {
          isEditable: true,
        };

        mountStatus(props);
      });

      it('shows the dropdown when the Edit button is clicked', () => {
        getEditButton(wrapper).trigger('click');

        return Vue.nextTick().then(() => {
          expect(wrapper.find('.dropdown').classes()).toContain('show');
        });
      });
    });

    describe('when visible', () => {
      beforeEach(() => {
        const props = {
          isEditable: true,
        };

        shallowMountStatus(props);

        wrapper.setData({ isDropdownShowing: true });
      });

      it('shows text to ask the user to pick an option', () => {
        const message = 'Assign health status';

        expect(
          getDropdownElement(wrapper)
            .find('.health-title')
            .text(),
        ).toContain(message);
      });

      it('hides form when the `edit` button is clicked', () => {
        getEditButton(wrapper).trigger('click');

        return Vue.nextTick().then(() => {
          expect(wrapper.find('.dropdown').classes()).toContain('d-none');
        });
      });

      it('hides form when a dropdown item is clicked', () => {
        const dropdownItem = wrapper.findAll(GlDropdownItem).at(1);

        dropdownItem.vm.$emit('click');

        return wrapper.vm.$nextTick().then(() => {
          expect(wrapper.find('.dropdown').classes()).toContain('d-none');
        });
      });
    });

    describe('dropdown', () => {
      const getIterableArray = arr => {
        return arr.map((value, index) => [value, index]);
      };

      beforeEach(() => {
        const props = {
          isEditable: true,
        };

        mountStatus(props);

        wrapper.setData({ isDropdownShowing: true });
      });

      it('shows 4 dropdown items', () => {
        expect(wrapper.findAll(GlDropdownItem)).toHaveLength(4);
      });

      // Test that "On track", "Needs attention", and "At risk" are displayed
      it.each(getIterableArray(Object.values(healthStatusTextMap)))(
        'shows "%s" text',
        (statusText, index) => {
          expect(
            wrapper
              .findAll(GlDropdownItem)
              .at(index + 1) // +1 in index to account for 1st item as `No status`
              .text(),
          ).toContain(statusText);
        },
      );

      // Test that "onTrack", "needsAttention", and "atRisk" values are emitted when form is submitted
      it.each(getIterableArray(Object.values(healthStatus)))(
        'emits onFormSubmit event with argument "%s" when user selects the option and submits form',
        (status, index) => {
          wrapper
            .findAll(GlDropdownItem)
            .at(index + 1)
            .vm.$emit('click', { preventDefault: () => null });

          return Vue.nextTick().then(() => {
            expect(wrapper.emitted().onDropdownClick[0]).toEqual([status]);
          });
        },
      );
    });
  });
});
