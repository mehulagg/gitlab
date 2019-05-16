import Vue from 'vue';
import component from 'ee/security_dashboard/components/filter.vue';
import createStore from 'ee/security_dashboard/store';
import { mountComponentWithStore } from 'helpers/vue_mount_component_helper';
import { setTestTimeout } from 'helpers/timeout';

setTestTimeout(500);

describe('Filter component', () => {
  let vm;
  let props;
  let store;
  let Component;

  function isDropdownOpen() {
    const toggleButton = vm.$el.querySelector('.dropdown-toggle');
    return toggleButton.getAttribute('aria-expanded') === 'true';
  }

  function setProjectsCount(count) {
    const projects = new Array(count).fill(null).map((_, i) => ({
      name: i.toString(),
      id: i.toString(),
    }));

    store.dispatch('filters/setFilterOptions', {
      filterId: 'project_id',
      options: projects,
    });
  }

  const findSearchInput = () => vm.$refs.searchBox && vm.$refs.searchBox.$el.querySelector('input');

  beforeEach(() => {
    store = createStore();
    Component = Vue.extend(component);
  });

  afterEach(() => {
    vm.$destroy();
  });

  describe('severity', () => {
    beforeEach(() => {
      props = { filterId: 'severity' };
      vm = mountComponentWithStore(Component, { store, props });
    });

    it('should display all 8 severity options', () => {
      expect(vm.$el.querySelectorAll('.dropdown-item').length).toEqual(8);
    });

    it('should display a check next to only the selected item', () => {
      expect(vm.$el.querySelectorAll('.dropdown-item .js-check').length).toEqual(1);
    });

    it('should display "Severity" as the option name', () => {
      expect(vm.$el.querySelector('.js-name').textContent).toContain('Severity');
    });

    it('should not have a search box', () => {
      expect(findSearchInput()).not.toEqual(jasmine.any(HTMLElement));
    });

    it('should not be open', () => {
      expect(isDropdownOpen()).toBe(false);
    });

    describe('when the dropdown is open', () => {
      beforeEach(done => {
        vm.$el.querySelector('.dropdown-toggle').click();
        vm.$nextTick(done);
      });

      it('should keep the menu open after clicking on an item', done => {
        expect(isDropdownOpen()).toBe(true);
        vm.$el.querySelector('.dropdown-item').click();
        vm.$nextTick(() => {
          expect(isDropdownOpen()).toBe(true);
          done();
        });
      });

      it('should close the menu when the close button is clicked', done => {
        expect(isDropdownOpen()).toBe(true);
        vm.$refs.close.click();
        vm.$nextTick(() => {
          expect(isDropdownOpen()).toBe(false);
          done();
        });
      });
    });
  });

  describe('Project', () => {
    describe('when there are lots of projects', () => {
      const lots = 30;
      beforeEach(done => {
        props = { filterId: 'project_id', dashboardDocumentation: '' };
        vm = mountComponentWithStore(Component, { store, props });
        setProjectsCount(lots);
        vm.$nextTick(done);
      });

      it('should display a search box', () => {
        expect(findSearchInput()).toEqual(jasmine.any(HTMLElement));
      });

      it(`should show all projects`, () => {
        expect(vm.$el.querySelectorAll('.dropdown-item').length).toBe(lots);
      });

      it('should show only matching projects when a search term is entered', done => {
        const input = findSearchInput();
        input.value = '0';
        input.dispatchEvent(new Event('input'));
        vm.$nextTick(() => {
          expect(vm.$el.querySelectorAll('.dropdown-item').length).toBe(3);
          done();
        });
      });
    });
  });
});
