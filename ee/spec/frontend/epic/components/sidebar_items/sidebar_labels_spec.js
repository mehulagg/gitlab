import Vuex from 'vuex';
import { mount, createLocalVue } from '@vue/test-utils';

import SidebarLabels from 'ee/epic/components/sidebar_items/sidebar_labels.vue';
import createStore from 'ee/epic/store';

import { mockEpicMeta, mockEpicData, mockLabels } from '../../mock_data';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('SidebarLabelsComponent', () => {
  let wrapper;
  let store;

  beforeEach(() => {
    store = createStore();
    store.dispatch('setEpicMeta', mockEpicMeta);
    store.dispatch('setEpicData', mockEpicData);

    wrapper = mount(SidebarLabels, {
      propsData: { canUpdate: false, sidebarCollapsed: false },
      store,
      stubs: {
        GlLabel: true,
      },
    });
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('data', () => {
    it('returns default data props', () => {
      expect(wrapper.vm.sidebarExpandedOnClick).toBe(false);
    });
  });

  describe('computed', () => {
    describe('epicContext', () => {
      it('returns object containing `this.labels` as a child prop', () => {
        expect(wrapper.vm.epicContext.labels).toBe(wrapper.vm.labels);
      });
    });
  });

  describe('methods', () => {
    describe('toggleSidebarRevealLabelsDropdown', () => {
      it('calls `toggleSidebar` action with param `sidebarCollapse`', () => {
        jest.spyOn(wrapper.vm, 'toggleSidebar');

        wrapper.vm.toggleSidebarRevealLabelsDropdown();

        expect(wrapper.vm.toggleSidebar).toHaveBeenCalledWith(
          expect.objectContaining({
            sidebarCollapsed: false,
          }),
        );
      });
    });

    describe('handleDropdownClose', () => {
      it('calls `toggleSidebar` action only when `sidebarExpandedOnClick` prop is true', () => {
        jest.spyOn(wrapper.vm, 'toggleSidebar');

        wrapper.setData({
          sidebarExpandedOnClick: true,
        });

        wrapper.vm.handleDropdownClose();

        expect(wrapper.vm.sidebarExpandedOnClick).toBe(false);
        expect(wrapper.vm.toggleSidebar).toHaveBeenCalledWith(
          expect.objectContaining({
            sidebarCollapsed: false,
          }),
        );
      });
    });

    describe('handleLabelClick', () => {
      const label = {
        id: 1,
        title: 'Foo',
        color: ['#BADA55'],
        text_color: '#FFFFFF',
      };

      beforeEach(() => {
        store.state.labels = mockLabels;
      });

      it('initializes `epicContext.labels` as empty array when `label.isAny` is `true`', () => {
        const labelIsAny = { isAny: true };
        wrapper.vm.handleLabelClick(labelIsAny);

        expect(Array.isArray(wrapper.vm.epicContext.labels)).toBe(true);
        expect(wrapper.vm.epicContext.labels).toHaveLength(0);
      });

      it('adds provided `label` to epicContext.labels', () => {
        wrapper.vm.handleLabelClick(label);
        // epicContext.labels gets initialized with initialLabels, hence
        // newly insert label will be at second position (index `1`)
        expect(wrapper.vm.epicContext.labels).toHaveLength(2);
        expect(wrapper.vm.epicContext.labels[1].id).toBe(label.id);
        wrapper.vm.handleLabelClick(label);
      });

      it('filters epicContext.labels to exclude provided `label` if it is already present in `epicContext.labels`', () => {
        wrapper.vm.handleLabelClick(label); // Select
        wrapper.vm.handleLabelClick(label); // Un-select

        expect(wrapper.vm.epicContext.labels).toHaveLength(1);
        expect(wrapper.vm.epicContext.labels[0].id).toBe(mockLabels[0].id);
      });
    });

    describe('handleUpdateSelectedLabels', () => {
      const updatingLabel = {
        id: 1,
        title: 'Foo Label',
        description: 'Foobar',
        color: '#BADA55',
        text_color: '#FFFFFF',
      };

      beforeEach(() => {
        jest.spyOn(wrapper.vm, 'updateEpicLabels').mockImplementation();
      });

      it('calls action `updateEpicLabels` when there is a label to apply', () => {
        store.state.labels = mockLabels;
        const appliedLabel = {
          ...updatingLabel,
          set: true,
        };

        wrapper.vm.handleUpdateSelectedLabels([appliedLabel]);

        expect(wrapper.vm.updateEpicLabels).toHaveBeenCalledWith(
          expect.arrayContaining([appliedLabel]),
        );
      });

      it('calls action `updateEpicLabels` when there is a label to remove', () => {
        const removedLabel = {
          ...updatingLabel,
          set: false,
        };

        store.state.labels = [...mockLabels, removedLabel];

        wrapper.vm.handleUpdateSelectedLabels([removedLabel]);

        expect(wrapper.vm.updateEpicLabels).toHaveBeenCalledWith(
          expect.arrayContaining([removedLabel]),
        );
      });

      it('does not call action `updateEpicLabels` when there are no labels to apply or remove', () => {
        const appliedLabel = {
          ...updatingLabel,
          set: true,
        };

        store.state.labels = [...mockLabels, appliedLabel];

        wrapper.vm.handleUpdateSelectedLabels([appliedLabel]);

        expect(wrapper.vm.updateEpicLabels).not.toHaveBeenCalled();
      });
    });
  });

  describe('template', () => {
    it('renders labels select element container', () => {
      expect(wrapper.classes('js-labels-block')).toBe(true);
    });
  });
});
