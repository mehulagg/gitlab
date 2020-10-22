import Vue from 'vue';

import EpicCreate from 'ee/epic/components/epic_create.vue';
import createStore from 'ee/epic/store';

import { mountComponentWithStore } from 'helpers/vue_mount_component_helper';
import { mockEpicMeta } from '../mock_data';

describe('EpicCreateComponent', () => {
  let vm;
  let store;

  beforeEach(() => {
    const Component = Vue.extend(EpicCreate);

    store = createStore();
    store.dispatch('setEpicMeta', mockEpicMeta);

    vm = mountComponentWithStore(Component, {
      store,
    });
  });

  afterEach(() => {
    vm.$destroy();
  });

  describe('computed', () => {
    describe('buttonLabel', () => {
      it('returns string `Create epic` when `epicCreateInProgress` is false', () => {
        vm.$store.state.epicCreateInProgress = false;

        expect(vm.buttonLabel).toBe('Create epic');
      });

      it('returns string `Creating epic` when `epicCreateInProgress` is true', () => {
        vm.$store.state.epicCreateInProgress = true;

        expect(vm.buttonLabel).toBe('Creating epic');
      });
    });

    describe('isEpicCreateDisabled', () => {
      it('returns `true` when `newEpicTitle` is an empty string', () => {
        vm.$store.state.newEpicTitle = '';

        expect(vm.isEpicCreateDisabled).toBe(true);
      });

      it('returns `false` when `newEpicTitle` is not empty', () => {
        vm.$store.state.newEpicTitle = 'foobar';

        expect(vm.isEpicCreateDisabled).toBe(false);
      });
    });

    describe('epicTitle', () => {
      describe('set', () => {
        it('calls `setEpicCreateTitle` with param `value`', () => {
          jest.spyOn(vm, 'setEpicCreateTitle');

          const newEpicTitle = 'foobar';

          vm.epicTitle = newEpicTitle;

          expect(vm.setEpicCreateTitle).toHaveBeenCalledWith(
            expect.objectContaining({
              newEpicTitle,
            }),
          );
        });
      });

      describe('get', () => {
        it('returns value of `newEpicTitle` from state', () => {
          const newEpicTitle = 'foobar';
          vm.$store.state.newEpicTitle = newEpicTitle;

          expect(vm.epicTitle).toBe(newEpicTitle);
        });
      });
    });

    describe('epicConfidential', () => {
      describe('set', () => {
        it('calls `setEpicCreateConfidential` with param `value`', () => {
          jest.spyOn(vm, 'setEpicCreateConfidential');

          const newEpicConfidential = true;

          vm.epicConfidential = newEpicConfidential;

          expect(vm.setEpicCreateConfidential).toHaveBeenCalledWith(
            expect.objectContaining({
              newEpicConfidential,
            }),
          );
        });
      });

      describe('get', () => {
        it('returns value of `newEpicConfidential` from state', () => {
          const newEpicConfidential = true;
          vm.$store.state.newEpicConfidential = newEpicConfidential;

          expect(vm.epicConfidential).toBe(newEpicConfidential);
        });
      });
    });
  });

  describe('template', () => {
    it('renders component container element with classes `dropdown` & `epic-create-dropdown`', () => {
      expect(vm.$el.classList.contains('dropdown')).toBe(true);
      expect(vm.$el.classList.contains('epic-create-dropdown')).toBe(true);
    });

    it('renders new epic button element', () => {
      const newEpicButtonEl = vm.$el.querySelector('button.btn-success');

      expect(newEpicButtonEl).not.toBeNull();
      expect(newEpicButtonEl.innerText.trim()).toBe('New epic');
    });

    it('renders new epic dropdown menu element', () => {
      const dropdownMenuEl = vm.$el.querySelector('.dropdown-menu');

      expect(dropdownMenuEl).not.toBeNull();
    });

    it('renders epic input textbox element', () => {
      const inputEl = vm.$el.querySelector('.dropdown-menu input.form-control');

      expect(inputEl).not.toBeNull();
      expect(inputEl.placeholder).toBe('Title');
    });

    it('renders create epic button element', () => {
      const createEpicButtonEl = vm.$el.querySelector('.dropdown-menu button.btn-success');

      expect(createEpicButtonEl).not.toBeNull();
      expect(createEpicButtonEl.innerText.trim()).toBe('Create epic');
    });
  });
});
