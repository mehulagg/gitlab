import { shallowMount, createLocalVue } from '@vue/test-utils';
import { GlLoadingIcon } from '@gitlab/ui';

import EpicsSelectBase from 'ee/vue_shared/components/sidebar/epics_select/base.vue';
import DropdownTitle from 'ee/vue_shared/components/sidebar/epics_select/dropdown_title.vue';
import DropdownValue from 'ee/vue_shared/components/sidebar/epics_select/dropdown_value.vue';
import DropdownValueCollapsed from 'ee/vue_shared/components/sidebar/epics_select/dropdown_value_collapsed.vue';

import DropdownButton from 'ee/vue_shared/components/sidebar/epics_select/dropdown_button.vue';
import DropdownHeader from 'ee/vue_shared/components/sidebar/epics_select/dropdown_header.vue';
import DropdownSearchInput from 'ee/vue_shared/components/sidebar/epics_select/dropdown_search_input.vue';
import DropdownContents from 'ee/vue_shared/components/sidebar/epics_select/dropdown_contents.vue';

import createDefaultStore from 'ee/vue_shared/components/sidebar/epics_select/store';

import {
  mockEpic1,
  mockEpic2,
  mockEpics,
  mockAssignRemoveRes,
  mockIssue,
  noneEpic,
} from '../mock_data';

describe('EpicsSelect', () => {
  describe('Base', () => {
    let wrapper;
    // const errorMessage = 'Something went wrong while fetching group epics.';
    const store = createDefaultStore();

    beforeEach(() => {
      setFixtures('<div class="flash-container"></div>');
      wrapper = shallowMount(EpicsSelectBase, {
        sync: false,
        store,
        localVue: createLocalVue(),

        propsData: {
          canEdit: true,
          blockTitle: 'Epic',
          initialEpic: mockEpic1,
          initialEpicLoading: false,
          epicIssueId: mockIssue.epic_issue_id,
          groupId: mockEpic1.group_id,
          issueId: mockIssue.id,
        },
      });
    });

    afterEach(() => {
      wrapper.destroy();
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

          expect(wrapper.vm.$store.state.selectedEpic).toBe(mockEpic2);
        });
      });
    });

    describe('methods', () => {
      describe('handleDropdownShown', () => {
        it('should call `fetchEpics` when `groupEpics` does not return any epics', done => {
          jest.spyOn(wrapper.vm, 'fetchEpics').mockReturnValue(
            Promise.resolve({
              data: mockEpics,
            }),
          );

          store.dispatch('receiveEpicsSuccess', []);

          wrapper.vm.$nextTick(() => {
            wrapper.vm.handleDropdownShown();

            expect(wrapper.vm.fetchEpics).toHaveBeenCalled();

            done();
          });
        });
      });

      describe('handleDropdownHidden', () => {
        it('should set `showDropdown` to false', () => {
          wrapper.vm.handleDropdownHidden();

          expect(wrapper.vm.showDropdown).toBe(false);
        });
      });

      describe('handleItemSelect', () => {
        it('should call `removeIssueFromEpic` with selected epic when `epic` param represents `No Epic`', () => {
          jest.spyOn(wrapper.vm, 'removeIssueFromEpic').mockReturnValue(
            Promise.resolve({
              data: mockAssignRemoveRes,
            }),
          );
          store.dispatch('setSelectedEpic', mockEpic1);

          wrapper.vm.handleItemSelect(noneEpic);

          expect(wrapper.vm.removeIssueFromEpic).toHaveBeenCalledWith(mockEpic1);
        });

        it('should call `assignIssueToEpic` with passed `epic` param when it does not represent `No Epic`', () => {
          jest.spyOn(wrapper.vm, 'assignIssueToEpic').mockReturnValue(
            Promise.resolve({
              data: mockAssignRemoveRes,
            }),
          );

          wrapper.vm.handleItemSelect(mockEpic2);

          expect(wrapper.vm.assignIssueToEpic).toHaveBeenCalledWith(mockEpic2);
        });
      });
    });

    describe('template', () => {
      const showDropdown = () => {
        wrapper.setProps({
          canEdit: true,
        });
        wrapper.setData({
          showDropdown: true,
        });
      };

      it('should render component container element', () => {
        expect(wrapper.classes()).toContain('js-epic-block');
      });

      it('should render DropdownValueCollapsed component', () => {
        expect(wrapper.find(DropdownValueCollapsed).exists()).toBe(true);
      });

      it('should render DropdownTitle component', () => {
        expect(wrapper.find(DropdownTitle).exists()).toBe(true);
      });

      it('should render DropdownValue component when `showDropdown` is false', done => {
        wrapper.vm.showDropdown = false;

        wrapper.vm.$nextTick(() => {
          expect(wrapper.find(DropdownValue).exists()).toBe(true);
          done();
        });
      });

      it('should render dropdown container element when props `canEdit` & `showDropdown` are true', done => {
        showDropdown();

        wrapper.vm.$nextTick(() => {
          expect(wrapper.find('.epic-dropdown-container').exists()).toBe(true);
          expect(wrapper.find('.epic-dropdown-container .dropdown').exists()).toBe(true);
          done();
        });
      });

      it('should render DropdownButton component when props `canEdit` & `showDropdown` are true', done => {
        showDropdown();

        wrapper.vm.$nextTick(() => {
          expect(wrapper.find(DropdownButton).exists()).toBe(true);
          done();
        });
      });

      it('should render dropdown menu container element when props `canEdit` & `showDropdown` are true', done => {
        showDropdown();

        wrapper.vm.$nextTick(() => {
          expect(wrapper.find('.dropdown .dropdown-menu.dropdown-menu-epics').exists()).toBe(true);
          done();
        });
      });

      it('should render DropdownHeader component when props `canEdit` & `showDropdown` are true', done => {
        showDropdown();

        wrapper.vm.$nextTick(() => {
          expect(wrapper.find(DropdownHeader).exists()).toBe(true);
          done();
        });
      });

      it('should render DropdownSearchInput component when props `canEdit` & `showDropdown` are true', done => {
        showDropdown();

        wrapper.vm.$nextTick(() => {
          expect(wrapper.find(DropdownSearchInput).exists()).toBe(true);
          done();
        });
      });

      it('should render DropdownContents component when props `canEdit` & `showDropdown` are true and `isEpicsLoading` is false', done => {
        showDropdown();
        store.dispatch('receiveEpicsSuccess', []);

        wrapper.vm.$nextTick(() => {
          expect(wrapper.find(DropdownContents).exists()).toBe(true);
          done();
        });
      });

      it('should render GlLoadingIcon component when props `canEdit` & `showDropdown` and `isEpicsLoading` are true', done => {
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
