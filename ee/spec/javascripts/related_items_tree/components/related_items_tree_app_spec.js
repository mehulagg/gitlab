import { shallowMount, createLocalVue } from '@vue/test-utils';
import { GlLoadingIcon } from '@gitlab/ui';

import RelatedItemsTreeApp from 'ee/related_items_tree/components/related_items_tree_app.vue';
import RelatedItemsTreeHeader from 'ee/related_items_tree/components/related_items_tree_header.vue';
import createDefaultStore from 'ee/related_items_tree/store';
import { ActionType } from 'ee/related_items_tree/constants';

import { mockInitialConfig, mockParentItem } from '../mock_data';

const createComponent = () => {
  const store = createDefaultStore();
  const localVue = createLocalVue();

  store.dispatch('setInitialConfig', mockInitialConfig);
  store.dispatch('setInitialParentItem', mockParentItem);

  return shallowMount(RelatedItemsTreeApp, {
    localVue,
    store,
  });
};

describe('RelatedItemsTreeApp', () => {
  let wrapper;

  beforeEach(() => {
    wrapper = createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  describe('methods', () => {
    describe('getRawRefs', () => {
      it('returns array of references from provided string with spaces', () => {
        const value = '&1 &2 &3';
        const references = wrapper.vm.getRawRefs(value);

        expect(references.length).toBe(3);
        expect(references.join(' ')).toBe(value);
      });
    });

    describe('handlePendingItemRemove', () => {
      it('calls `removePendingReference` action with provided `index` param', () => {
        spyOn(wrapper.vm, 'removePendingReference');

        wrapper.vm.handlePendingItemRemove(0);

        expect(wrapper.vm.removePendingReference).toHaveBeenCalledWith(0);
      });
    });

    describe('handleAddItemFormInput', () => {
      const untouchedRawReferences = ['&1'];
      const touchedReference = '&2';

      it('calls `addPendingReferences` action with provided `untouchedRawReferences` param', () => {
        spyOn(wrapper.vm, 'addPendingReferences');

        wrapper.vm.handleAddItemFormInput({ untouchedRawReferences, touchedReference });

        expect(wrapper.vm.addPendingReferences).toHaveBeenCalledWith(untouchedRawReferences);
      });

      it('calls `setItemInputValue` action with provided `touchedReference` param', () => {
        spyOn(wrapper.vm, 'setItemInputValue');

        wrapper.vm.handleAddItemFormInput({ untouchedRawReferences, touchedReference });

        expect(wrapper.vm.setItemInputValue).toHaveBeenCalledWith(touchedReference);
      });
    });

    describe('handleAddItemFormBlur', () => {
      const newValue = '&1 &2';

      it('calls `addPendingReferences` action with provided `newValue` param', () => {
        spyOn(wrapper.vm, 'addPendingReferences');

        wrapper.vm.handleAddItemFormBlur(newValue);

        expect(wrapper.vm.addPendingReferences).toHaveBeenCalledWith(newValue.split(/\s+/));
      });

      it('calls `setItemInputValue` action with empty string', () => {
        spyOn(wrapper.vm, 'setItemInputValue');

        wrapper.vm.handleAddItemFormBlur(newValue);

        expect(wrapper.vm.setItemInputValue).toHaveBeenCalledWith('');
      });
    });

    describe('handleAddItemFormSubmit', () => {
      it('calls `addItem` action when `pendingReferences` prop in state is not empty', () => {
        const newValue = '&1 &2';
        spyOn(wrapper.vm, 'addItem');

        wrapper.vm.handleAddItemFormSubmit(newValue);

        expect(wrapper.vm.addItem).toHaveBeenCalled();
      });
    });

    describe('handleCreateEpicFormSubmit', () => {
      it('calls `createItem` action with `itemTitle` param', () => {
        const newValue = 'foo';
        spyOn(wrapper.vm, 'createItem');

        wrapper.vm.handleCreateEpicFormSubmit(newValue);

        expect(wrapper.vm.createItem).toHaveBeenCalledWith({
          itemTitle: newValue,
        });
      });
    });

    describe('handleAddItemFormCancel', () => {
      it('calls `toggleAddItemForm` actions with params `toggleState` as true and `actionType` as `ActionType.Epic`', () => {
        spyOn(wrapper.vm, 'toggleAddItemForm');

        wrapper.vm.handleAddItemFormCancel();

        expect(wrapper.vm.toggleAddItemForm).toHaveBeenCalledWith({
          toggleState: false,
          actionType: '',
        });
      });

      it('calls `setPendingReferences` action with empty array', () => {
        spyOn(wrapper.vm, 'setPendingReferences');

        wrapper.vm.handleAddItemFormCancel();

        expect(wrapper.vm.setPendingReferences).toHaveBeenCalledWith([]);
      });

      it('calls `setItemInputValue` action with empty string', () => {
        spyOn(wrapper.vm, 'setItemInputValue');

        wrapper.vm.handleAddItemFormCancel();

        expect(wrapper.vm.setItemInputValue).toHaveBeenCalledWith('');
      });
    });

    describe('handleCreateEpicFormCancel', () => {
      it('calls `toggleCreateEpicForm` actions with params `toggleState` and `actionType`', () => {
        spyOn(wrapper.vm, 'toggleCreateEpicForm');

        wrapper.vm.handleCreateEpicFormCancel();

        expect(wrapper.vm.toggleCreateEpicForm).toHaveBeenCalledWith({
          toggleState: false,
          actionType: '',
        });
      });

      it('calls `setItemInputValue` action with empty string', () => {
        spyOn(wrapper.vm, 'setItemInputValue');

        wrapper.vm.handleCreateEpicFormCancel();

        expect(wrapper.vm.setItemInputValue).toHaveBeenCalledWith('');
      });
    });
  });

  describe('template', () => {
    beforeEach(() => {
      wrapper.vm.$store.dispatch('receiveItemsSuccess', {
        parentItem: mockParentItem,
        children: [],
        isSubItem: false,
      });
    });

    it('renders loading icon when `state.itemsFetchInProgress` prop is true', done => {
      wrapper.vm.$store.dispatch('requestItems', {
        parentItem: mockParentItem,
        isSubItem: false,
      });

      wrapper.vm.$nextTick(() => {
        expect(wrapper.find(GlLoadingIcon).isVisible()).toBe(true);
        done();
      });
    });

    it('renders tree container element when `state.itemsFetchInProgress` prop is false', done => {
      wrapper.vm.$nextTick(() => {
        expect(wrapper.find('.related-items-tree').isVisible()).toBe(true);
        done();
      });
    });

    it('renders tree container element with `disabled-content` class when `state.itemsFetchInProgress` prop is false and `state.itemAddInProgress` or `state.itemCreateInProgress` is true', done => {
      wrapper.vm.$store.dispatch('requestAddItem');

      wrapper.vm.$nextTick(() => {
        expect(wrapper.find('.related-items-tree.disabled-content').isVisible()).toBe(true);
        done();
      });
    });

    it('renders tree header component', done => {
      wrapper.vm.$nextTick(() => {
        expect(wrapper.find(RelatedItemsTreeHeader).isVisible()).toBe(true);
        done();
      });
    });

    it('renders item add/create form container element', done => {
      wrapper.vm.$store.dispatch('toggleAddItemForm', {
        toggleState: true,
        actionType: ActionType.Epic,
      });

      wrapper.vm.$nextTick(() => {
        expect(wrapper.find('.add-item-form-container').isVisible()).toBe(true);
        done();
      });
    });
  });
});
