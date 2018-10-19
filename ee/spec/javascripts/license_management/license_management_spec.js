import Vue from 'vue';
import Vuex from 'vuex';
import LicenseManagement from 'ee/vue_shared/license_management/license_management.vue';
import { mountComponentWithStore } from 'spec/helpers/vue_mount_component_helper';
import { trimText } from 'spec/helpers/vue_component_helper';
import { TEST_HOST } from 'spec/test_constants';
import { approvedLicense, blacklistedLicense } from 'ee_spec/license_management/mock_data';

describe('LicenseManagement', () => {
  const Component = Vue.extend(LicenseManagement);
  const apiUrl = `${TEST_HOST}/license_management`;
  let vm;
  let store;
  let actions;

  beforeEach(() => {
    actions = {
      setAPISettings: jasmine.createSpy('setAPISettings').and.callFake(() => {}),
      loadManagedLicenses: jasmine.createSpy('loadManagedLicenses').and.callFake(() => {}),
    };

    store = new Vuex.Store({
      state: {
        managedLicenses: [approvedLicense, blacklistedLicense],
        currentLicenseInModal: approvedLicense,
        isLoadingManagedLicenses: true,
      },
      actions,
    });
    vm = mountComponentWithStore(Component, { props: { apiUrl }, store });
  });

  afterEach(() => {
    vm.$destroy();
  });

  describe('License Form', () => {
    it('should render the form if the form is open', done => {
      vm.formIsOpen = true;

      return Vue.nextTick().then(() => {
        const formEl = vm.$el.querySelector('.js-add-license-form');

        expect(formEl).not.toBeNull();
        const buttonEl = vm.$el.querySelector('.js-open-form');

        expect(buttonEl).toBeNull();
        done();
      }).catch(done.fail);
    });

    it('should render the button if the form is closed', done => {
      vm.formIsOpen = false;

      return Vue.nextTick().then(() => {
        const formEl = vm.$el.querySelector('.js-add-license-form');

        expect(formEl).toBeNull();
        const buttonEl = vm.$el.querySelector('.js-open-form');

        expect(buttonEl).not.toBeNull();
        done();
      }).catch(done.fail);
    });

    it('clicking the Add a license button opens the form', () => {
      const linkEl = vm.$el.querySelector('.js-open-form');

      expect(vm.formIsOpen).toBe(false);

      linkEl.click();

      expect(vm.formIsOpen).toBe(true);
    });
  });

  it('should render loading icon', done => {
    store.replaceState({ ...store.state, isLoadingManagedLicenses: true });

    return Vue.nextTick().then(() => {
      expect(vm.$el.querySelector('.loading-container')).not.toBeNull();
      done();
    }).catch(done.fail);
  });

  it('should render callout if no licenses are managed', done => {
    store.replaceState({ ...store.state, managedLicenses: [], isLoadingManagedLicenses: false });

    return Vue.nextTick().then(() => {
      const callout = vm.$el.querySelector('.bs-callout');

      expect(callout).not.toBeNull();
      expect(trimText(callout.innerText)).toBe(vm.$options.emptyMessage);
      done();
    }).catch(done.fail);
  });

  it('should render delete confirmation modal', done => {
    store.replaceState({ ...store.state });

    return Vue.nextTick().then(() => {
      expect(vm.$el.querySelector('#modal-license-delete-confirmation')).not.toBeNull();
      done();
    }).catch(done.fail);
  });

  it('should render list of managed licenses', done => {
    store.replaceState({ ...store.state, isLoadingManagedLicenses: false });

    return Vue.nextTick().then(() => {
      expect(vm.$el.querySelector('.list-group')).not.toBeNull();
      expect(vm.$el.querySelector('.list-group .list-group-item')).not.toBeNull();
      expect(vm.$el.querySelectorAll('.list-group .list-group-item').length).toBe(2);
      done();
    }).catch(done.fail);
  });

  it('should set api settings after mount and init API calls', () =>
    Vue.nextTick().then(() => {
      expect(actions.setAPISettings).toHaveBeenCalledWith(
        jasmine.any(Object),
        { apiUrlManageLicenses: apiUrl },
        undefined,
      );

      expect(actions.loadManagedLicenses).toHaveBeenCalledWith(
        jasmine.any(Object),
        undefined,
        undefined,
      );
    }));
});
