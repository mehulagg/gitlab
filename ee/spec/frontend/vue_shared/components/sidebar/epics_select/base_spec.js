import { GlLoadingIcon } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';

import { DropdownVariant } from 'ee/vue_shared/components/sidebar/epics_select//constants';
import EpicsSelectBase from 'ee/vue_shared/components/sidebar/epics_select/base.vue';
import DropdownButton from 'ee/vue_shared/components/sidebar/epics_select/dropdown_button.vue';
import DropdownContents from 'ee/vue_shared/components/sidebar/epics_select/dropdown_contents.vue';
import DropdownHeader from 'ee/vue_shared/components/sidebar/epics_select/dropdown_header.vue';
import DropdownSearchInput from 'ee/vue_shared/components/sidebar/epics_select/dropdown_search_input.vue';
import DropdownTitle from 'ee/vue_shared/components/sidebar/epics_select/dropdown_title.vue';
import DropdownValue from 'ee/vue_shared/components/sidebar/epics_select/dropdown_value.vue';
import DropdownValueCollapsed from 'ee/vue_shared/components/sidebar/epics_select/dropdown_value_collapsed.vue';

import createDefaultStore from 'ee/vue_shared/components/sidebar/epics_select/store';

import { mockEpic1, mockEpic2, mockAssignRemoveRes, mockIssue, noneEpic } from '../mock_data';

describe('EpicsSelect', () => {
  describe('Base', () => {
    let wrapper;
    let wrapperStandalone;
    // const errorMessage = 'Something went wrong while fetching group epics.';
    const store = createDefaultStore();
    const storeStandalone = createDefaultStore();

    beforeEach(() => {
      setFixtures('<div class="flash-container"></div>');
      const props = {
        canEdit: true,
        initialEpic: mockEpic1,
        initialEpicLoading: false,
        epicIssueId: mockIssue.epic_issue_id,
        groupId: mockEpic1.group_id,
        issueId: mockIssue.id,
      };

      wrapper = shallowMount(EpicsSelectBase, {
        store,
        propsData: {
          ...props,
        },
      });

      wrapperStandalone = shallowMount(EpicsSelectBase, {
        store: storeStandalone,
        propsData: {
          ...props,
          variant: DropdownVariant.Standalone,
        },
      });
    });

    afterEach(() => {
      wrapper.destroy();
      wrapperStandalone.destroy();
    });

    describe('computed', () => {
      describe('dropdownButtonTextClass', () => {
        it('should return object { is-default: true } when variant is "standalone"', () => {
          expect(wrapperStandalone.vm.dropdownButtonTextClass).toEqual(
            expect.objectContaining({
              'is-default': true,
            }),
          );
        });

        it('should return object { is-default: false } when variant is "sidebar"', () => {
          expect(wrapper.vm.dropdownButtonTextClass).toEqual(
            expect.objectContaining({
              'is-default': false,
            }),
          );
        });
      });
    });

    describe('watchers', () => {
      describe('issueId', () => {
        it('should update `issueId` within state when prop is updated', () => {
          wrapper.setProps({
            issueId: 123,
          });

          return wrapper.vm.$nextTick().then(() => {
            expect(wrapper.vm.$store.state.issueId).toBe(123);
          });
        });
      });

      describe('initialEpic', () => {
        it('should update `selectedEpic` within state when prop is updated', () => {
          wrapper.setProps({
            initialEpic: mockEpic2,
          });

          return wrapper.vm.$nextTick().then(() => {
            expect(wrapper.vm.$store.state.selectedEpic).toBe(mockEpic2);
          });
        });
      });

      describe('initialEpicLoading', () => {
        it('should update `selectedEpic` within state when prop is updated', () => {
          wrapper.setProps({
            initialEpic: mockEpic2,
          });

          return wrapper.vm.$nextTick().then(() => {
            expect(wrapper.vm.$store.state.selectedEpic).toBe(mockEpic2);
          });
        });
      });

      describe('searchQuery', () => {
        beforeEach(() => {
          jest.spyOn(wrapper.vm, 'fetchEpics').mockImplementation(jest.fn());
        });

        it('should call action `fetchEpics` with `searchQuery` when value is set and `groupEpics` is empty', () => {
          wrapper.vm.$store.dispatch('setSearchQuery', 'foo');

          return wrapper.vm.$nextTick(() => {
            expect(wrapper.vm.fetchEpics).toHaveBeenCalledWith('foo');
          });
        });

        it('should call action `fetchEpics` without any params when value is empty', () => {
          wrapper.vm.$store.dispatch('setSearchQuery', '');

          return wrapper.vm.$nextTick(() => {
            expect(wrapper.vm.fetchEpics).toHaveBeenCalledWith();
          });
        });
      });
    });

    describe('methods', () => {
      describe('handleDropdownHidden', () => {
        it('should set `showDropdown` to false', () => {
          wrapper.vm.handleDropdownHidden();

          expect(wrapper.vm.showDropdown).toBe(false);
        });

        it('should set `showDropdown` to true when dropdown variant is "standalone"', () => {
          wrapperStandalone.vm.handleDropdownHidden();

          expect(wrapperStandalone.vm.showDropdown).toBe(true);
        });
      });

      describe('handleItemSelect', () => {
        it('should call `removeIssueFromEpic` with selected epic when `epic` param represents `No Epic` and `epicIssueId` is defined', () => {
          jest.spyOn(wrapper.vm, 'removeIssueFromEpic').mockReturnValue(
            Promise.resolve({
              data: mockAssignRemoveRes,
            }),
          );
          store.dispatch('setSelectedEpic', mockEpic1);

          wrapper.vm.handleItemSelect(noneEpic);

          expect(wrapper.vm.removeIssueFromEpic).toHaveBeenCalledWith(mockEpic1);
        });

        it('should call `assignIssueToEpic` with passed `epic` param when it does not represent `No Epic` and `issueId` prop is defined', () => {
          jest.spyOn(wrapper.vm, 'assignIssueToEpic').mockReturnValue(
            Promise.resolve({
              data: mockAssignRemoveRes,
            }),
          );

          wrapper.vm.handleItemSelect(mockEpic2);

          expect(wrapper.vm.assignIssueToEpic).toHaveBeenCalledWith(mockEpic2);
        });

        it('should emit component event `epicSelect` with both `epicIssueId` & `issueId` props are not defined', () => {
          wrapperStandalone.setProps({
            issueId: 0,
            epicIssueId: 0,
          });

          return wrapperStandalone.vm.$nextTick(() => {
            wrapperStandalone.vm.handleItemSelect(mockEpic2);

            expect(wrapperStandalone.emitted('epicSelect')).toBeTruthy();
            expect(wrapperStandalone.emitted('epicSelect')[0]).toEqual([mockEpic2]);
          });
        });
      });
    });

    describe('template', () => {
      const showDropdown = (w = wrapper) => {
        w.setProps({
          canEdit: true,
        });
        w.setData({
          showDropdown: true,
        });
      };

      it('should render component container element', () => {
        expect(wrapper.classes()).toEqual(['js-epic-block', 'block', 'epic']);

        expect(wrapperStandalone.classes()).toEqual(['js-epic-block']);
      });

      it('should render DropdownValueCollapsed component', () => {
        expect(wrapper.find(DropdownValueCollapsed).exists()).toBe(true);
      });

      it('should not render DropdownValueCollapsed component when variant is "standalone"', () => {
        expect(wrapperStandalone.find(DropdownValueCollapsed).exists()).toBe(false);
      });

      it('should render DropdownTitle component', () => {
        expect(wrapper.find(DropdownTitle).exists()).toBe(true);
      });

      it('should not render DropdownTitle component when variant is "standalone"', () => {
        expect(wrapperStandalone.find(DropdownTitle).exists()).toBe(false);
      });

      it('should render DropdownValue component when `showDropdown` is false', (done) => {
        wrapper.vm.showDropdown = false;

        wrapper.vm.$nextTick(() => {
          expect(wrapper.find(DropdownValue).exists()).toBe(true);
          done();
        });
      });

      it('should not render DropdownValue component when variant is "standalone"', () => {
        expect(wrapperStandalone.find(DropdownValue).exists()).toBe(false);
      });

      it('should render dropdown container element when props `canEdit` & `showDropdown` are true', (done) => {
        showDropdown();

        wrapper.vm.$nextTick(() => {
          expect(wrapper.find('.epic-dropdown-container').exists()).toBe(true);
          expect(wrapper.find('.epic-dropdown-container .dropdown').exists()).toBe(true);
          done();
        });
      });

      it('should render dropdown container element when variant is "standalone"', () => {
        expect(wrapperStandalone.find('.epic-dropdown-container').exists()).toBe(true);
      });

      it('should render DropdownButton component when props `canEdit` & `showDropdown` are true', (done) => {
        showDropdown();

        wrapper.vm.$nextTick(() => {
          expect(wrapper.find(DropdownButton).exists()).toBe(true);
          done();
        });
      });

      it('should render dropdown menu container element when props `canEdit` & `showDropdown` are true', (done) => {
        showDropdown();

        wrapper.vm.$nextTick(() => {
          expect(wrapper.find('.dropdown .dropdown-menu.dropdown-menu-epics').exists()).toBe(true);
          done();
        });
      });

      it('should render DropdownHeader component when props `canEdit` & `showDropdown` are true', (done) => {
        showDropdown();

        wrapper.vm.$nextTick(() => {
          expect(wrapper.find(DropdownHeader).exists()).toBe(true);
          done();
        });
      });

      it('should not render DropdownHeader component when variant is "standalone"', () => {
        showDropdown(wrapperStandalone);

        return wrapperStandalone.vm.$nextTick(() => {
          expect(wrapperStandalone.find(DropdownHeader).exists()).toBe(false);
        });
      });

      it('should render DropdownSearchInput component when props `canEdit` & `showDropdown` are true', (done) => {
        showDropdown();

        wrapper.vm.$nextTick(() => {
          expect(wrapper.find(DropdownSearchInput).exists()).toBe(true);
          done();
        });
      });

      it('should render DropdownContents component when props `canEdit` & `showDropdown` are true and `isEpicsLoading` is false', (done) => {
        showDropdown();
        store.dispatch('receiveEpicsSuccess', []);

        wrapper.vm.$nextTick(() => {
          expect(wrapper.find(DropdownContents).exists()).toBe(true);
          done();
        });
      });

      it('should render GlLoadingIcon component when props `canEdit` & `showDropdown` and `isEpicsLoading` are true', (done) => {
        showDropdown();
        store.dispatch('requestEpics');

        wrapper.vm.$nextTick(() => {
          expect(wrapper.find(GlLoadingIcon).exists()).toBe(true);
          done();
        });
      });
    });
  });
});
