import Vue from 'vue';
import _ from 'underscore';
import { mount } from '@vue/test-utils';
import PackagesList from 'ee/packages/list/components/packages_list.vue';
import stubChildren from 'helpers/stub_children';
import { packageList } from '../../mock_data';

describe('packages_list', () => {
  let wrapper;

  const findFirstActionColumn = () => wrapper.find({ ref: 'action-delete' });
  const findPackageListTable = () => wrapper.find({ ref: 'packageListTable' });
  const findPackageListSorting = () => wrapper.find({ ref: 'packageListSorting' });
  const findPackageListPagination = () => wrapper.find({ ref: 'packageListPagination' });
  const findPackageListDeleteModal = () => wrapper.find({ ref: 'packageListDeleteModal' });
  const findSortingItems = () => wrapper.findAll({ name: 'sorting-item-stub' });
  const findFirstProjectColumn = () => wrapper.find({ ref: 'col-project' });

  const mountOptions = {
    stubs: {
      ...stubChildren(PackagesList),
      GlTable: false,
      GlSortingItem: { name: 'sorting-item-stub', template: '<div><slot></slot></div>' },
    },
    computed: {
      list: () => [...packageList],
      perPage: () => 1,
      totalItems: () => 1,
      page: () => 1,
      canDestroyPackage: () => true,
      isGroupPage: () => false,
    },
  };

  beforeEach(() => {
    // This is needed due to  console.error called by vue to emit a warning that stop the tests
    // see  https://github.com/vuejs/vue-test-utils/issues/532
    Vue.config.silent = true;
    wrapper = mount(PackagesList, mountOptions);
  });

  afterEach(() => {
    Vue.config.silent = false;
    wrapper.destroy();
  });

  describe('when is isGroupPage', () => {
    beforeEach(() => {
      wrapper = mount(PackagesList, {
        ...mountOptions,
        computed: {
          ...mountOptions.computed,
          canDestroyPackage: () => false,
          isGroupPage: () => true,
        },
      });
    });

    it('has project field', () => {
      const projectColumn = findFirstProjectColumn();
      expect(projectColumn.exists()).toBe(true);
    });
  });

  it('contains a sorting component', () => {
    const sorting = findPackageListSorting();
    expect(sorting.exists()).toBe(true);
  });

  it('contains a table component', () => {
    const sorting = findPackageListTable();
    expect(sorting.exists()).toBe(true);
  });

  it('contains a pagination component', () => {
    const sorting = findPackageListPagination();
    expect(sorting.exists()).toBe(true);
  });
  it('contains a modal component', () => {
    const sorting = findPackageListDeleteModal();
    expect(sorting.exists()).toBe(true);
  });

  describe('when user can not destroy the package', () => {
    beforeEach(() => {
      wrapper = mount(PackagesList, {
        ...mountOptions,
        computed: { ...mountOptions.computed, canDestroyPackage: () => false },
      });
    });

    it('does not show the action column', () => {
      const action = findFirstActionColumn();
      expect(action.exists()).toBe(false);
    });
  });

  describe('when the user can destroy the package', () => {
    it('show the action column', () => {
      const action = findFirstActionColumn();
      expect(action.exists()).toBe(true);
    });

    it('shows the correct deletePackageDescription', () => {
      expect(wrapper.vm.deletePackageDescription).toEqual('');

      wrapper.setData({ itemToBeDeleted: { name: 'foo', version: '1.0.10-beta' } });
      expect(wrapper.vm.deletePackageDescription).toMatchInlineSnapshot(
        `"You are about to delete <b>foo:1.0.10-beta</b>, this operation is irreversible, are you sure?"`,
      );
    });

    it('delete button set itemToBeDeleted and open the modal', () => {
      wrapper.vm.$refs.packageListDeleteModal.show = jest.fn();
      const item = _.last(packageList);
      const action = findFirstActionColumn();
      action.vm.$emit('click');
      return Vue.nextTick().then(() => {
        expect(wrapper.vm.itemToBeDeleted).toEqual(item);
        expect(wrapper.vm.$refs.packageListDeleteModal.show).toHaveBeenCalled();
      });
    });

    it('deleteItemConfirmation resets itemToBeDeleted', () => {
      wrapper.setData({ itemToBeDeleted: 1 });
      wrapper.vm.deleteItemConfirmation();
      expect(wrapper.vm.itemToBeDeleted).toEqual(null);
    });
    it('deleteItemConfirmation emit package:delete', () => {
      wrapper.setData({ itemToBeDeleted: { id: 2 } });
      wrapper.vm.deleteItemConfirmation();
      return wrapper.vm.$nextTick(() => {
        expect(wrapper.emitted('package:delete')).toEqual([[2]]);
      });
    });

    it('deleteItemCanceled resets itemToBeDeleted', () => {
      wrapper.setData({ itemToBeDeleted: 1 });
      wrapper.vm.deleteItemCanceled();
      expect(wrapper.vm.itemToBeDeleted).toEqual(null);
    });
  });

  describe('when the list is empty', () => {
    const findEmptySlot = () => wrapper.find({ name: 'empty-slot-stub' });

    beforeEach(() => {
      wrapper = mount(PackagesList, {
        ...mountOptions,
        computed: { list: () => [] },
        slots: {
          'empty-state': { name: 'empty-slot-stub', template: '<div>bar</div>' },
        },
      });
    });

    it('show the empty slot', () => {
      const table = findPackageListTable();
      const emptySlot = findEmptySlot();
      expect(table.exists()).toBe(false);
      expect(emptySlot.exists()).toBe(true);
    });
  });

  describe('sorting component', () => {
    it('has all the sortable items', () => {
      const sortingItems = findSortingItems();
      expect(sortingItems.length).toEqual(wrapper.vm.sortableFields.length);
    });
    it('emits page:changed events when the page changes', () => {
      wrapper.vm.currentPage = 2;
      expect(wrapper.emitted('page:changed')).toEqual([[2]]);
    });
  });

  describe('table component', () => {
    it('has stacked-md class', () => {
      const table = findPackageListTable();
      expect(table.classes()).toContain('b-table-stacked-md');
    });
  });
});
