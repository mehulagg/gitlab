import { shallowMount, createLocalVue } from '@vue/test-utils';
import { GlButton } from '@gitlab/ui';

import RelatedItemsTreeHeader from 'ee/related_items_tree/components/related_items_tree_header.vue';
import Icon from '~/vue_shared/components/icon.vue';
import DroplabDropdownButton from '~/vue_shared/components/droplab_dropdown_button.vue';
import createDefaultStore from 'ee/related_items_tree/store';
import * as epicUtils from 'ee/related_items_tree/utils/epic_utils';
import { ActionType } from 'ee/related_items_tree/constants';

import { mockParentItem, mockQueryResponse } from '../mock_data';

const createComponent = () => {
  const store = createDefaultStore();
  const localVue = createLocalVue();
  const children = epicUtils.processQueryResponse(mockQueryResponse.data.group);

  store.dispatch('setInitialParentItem', mockParentItem);
  store.dispatch('setItemChildren', {
    parentItem: mockParentItem,
    isSubItem: false,
    children,
  });
  store.dispatch('setItemChildrenFlags', {
    isSubItem: false,
    children,
  });

  return shallowMount(RelatedItemsTreeHeader, {
    localVue,
    store,
  });
};

describe('RelatedItemsTree', () => {
  describe('RelatedItemsTreeHeader', () => {
    let wrapper;

    beforeEach(() => {
      wrapper = createComponent();
    });

    afterEach(() => {
      wrapper.destroy();
    });

    describe('computed', () => {
      describe('badgeTooltip', () => {
        it('returns string containing epic count and issues count based on available direct children within state', () => {
          expect(wrapper.vm.badgeTooltip).toBe('2 epics and 2 issues');
        });
      });
    });

    describe('methods', () => {
      describe('handleActionClick', () => {
        const actionType = ActionType.Epic;

        it('calls `toggleAddItemForm` action when provided `id` param as value `0`', () => {
          spyOn(wrapper.vm, 'toggleAddItemForm');

          wrapper.vm.handleActionClick({
            id: 0,
            actionType,
          });

          expect(wrapper.vm.toggleAddItemForm).toHaveBeenCalledWith({
            actionType,
            toggleState: true,
          });
        });

        it('calls `toggleCreateEpicForm` action when provided `id` param value is not `0`', () => {
          spyOn(wrapper.vm, 'toggleCreateEpicForm');

          wrapper.vm.handleActionClick({
            id: 1,
            actionType,
          });

          expect(wrapper.vm.toggleCreateEpicForm).toHaveBeenCalledWith({
            actionType,
            toggleState: true,
          });
        });
      });
    });

    describe('template', () => {
      it('renders item badges container', () => {
        const badgesContainerEl = wrapper.find('.issue-count-badge');

        expect(badgesContainerEl.isVisible()).toBe(true);
      });

      it('renders epics count and icon', () => {
        const epicsEl = wrapper.findAll('.issue-count-badge > span').at(0);
        const epicIcon = epicsEl.find(Icon);

        expect(epicsEl.text().trim()).toBe('2');
        expect(epicIcon.isVisible()).toBe(true);
        expect(epicIcon.props('name')).toBe('epic');
      });

      it('renders issues count and icon', () => {
        const issuesEl = wrapper.findAll('.issue-count-badge > span').at(1);
        const issueIcon = issuesEl.find(Icon);

        expect(issuesEl.text().trim()).toBe('2');
        expect(issueIcon.isVisible()).toBe(true);
        expect(issueIcon.props('name')).toBe('issues');
      });

      it('renders `Add an epic` dropdown button', () => {
        expect(wrapper.find(DroplabDropdownButton).isVisible()).toBe(true);
      });

      it('renders `Add an issue` dropdown button', () => {
        const addIssueBtn = wrapper.find(GlButton);

        expect(addIssueBtn.isVisible()).toBe(true);
        expect(addIssueBtn.text()).toBe('Add an issue');
      });
    });
  });
});
