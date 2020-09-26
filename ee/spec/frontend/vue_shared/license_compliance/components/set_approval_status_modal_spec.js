import Vue from 'vue';
import Vuex from 'vuex';

import SetApprovalModal from 'ee/vue_shared/license_compliance/components/set_approval_status_modal.vue';
import { LICENSE_APPROVAL_STATUS } from 'ee/vue_shared/license_compliance/constants';
import { trimText } from 'helpers/text_helper';
import { mountComponentWithStore } from 'helpers/vue_mount_component_helper';
import { licenseReport } from '../mock_data';

Vue.use(Vuex);

describe('SetApprovalModal', () => {
  const Component = Vue.extend(SetApprovalModal);

  let vm;
  let store;
  let actions;

  beforeEach(() => {
    actions = {
      resetLicenseInModal: jest.fn(),
    };

    store = new Vuex.Store({
      modules: {
        licenseManagement: {
          namespaced: true,
          state: {
            currentLicenseInModal: licenseReport[0],
            canManageLicenses: true,
          },
          actions,
        },
      },
    });

    vm = mountComponentWithStore(Component, { store });
  });

  afterEach(() => {
    vm.$destroy();
  });

  describe('renders the modal title', () => {
    describe('computed', () => {
      it('headerTitleText returns `License details`', () => {
        expect(vm.headerTitleText).toBe('License details');
      });
    });
  });

  describe('Modal Body', () => {
    it('renders the license name', () => {
      const licenseName = vm.$el.querySelector('.js-license-name');

      expect(licenseName).not.toBeNull();
      expect(trimText(licenseName.innerText)).toBe(`License: ${licenseReport[0].name}`);
    });

    it('renders the license url with link', () => {
      const licenseName = vm.$el.querySelector('.js-license-url');

      expect(licenseName).not.toBeNull();
      expect(trimText(licenseName.innerText)).toBe(`URL: ${licenseReport[0].url}`);

      const licenseLink = licenseName.querySelector('a');

      expect(licenseLink.getAttribute('href')).toBe(licenseReport[0].url);
      expect(trimText(licenseLink.innerText)).toBe(licenseReport[0].url);
    });

    it('renders the license url', () => {
      const licenseName = vm.$el.querySelector('.js-license-packages');

      expect(licenseName).not.toBeNull();
      expect(trimText(licenseName.innerText)).toBe('Packages: Used by pg, puma, foo, and 2 more');
    });
  });

  describe('interaction', () => {
    describe('triggering resetLicenseInModal on canceling', () => {
      it('by clicking the cancel button', () => {
        const linkEl = vm.$el.querySelector('.js-modal-cancel-action');
        linkEl.click();

        expect(actions.resetLicenseInModal).toHaveBeenCalled();
      });

      it('triggering resetLicenseInModal by clicking the X button', () => {
        const linkEl = vm.$el.querySelector('.js-modal-close-action');
        linkEl.click();

        expect(actions.resetLicenseInModal).toHaveBeenCalled();
      });
    });
  });

  it('does not render a XSS link', done => {
    // eslint-disable-next-line no-script-url
    const badURL = 'javascript:alert("")';

    store.replaceState({
      licenseManagement: {
        currentLicenseInModal: {
          ...licenseReport[0],
          url: badURL,
          approvalStatus: LICENSE_APPROVAL_STATUS.ALLOWED,
        },
      },
    });
    Vue.nextTick()
      .then(() => {
        const licenseName = vm.$el.querySelector('.js-license-url');

        expect(licenseName).not.toBeNull();
        expect(trimText(licenseName.innerText)).toBe(`URL: ${badURL}`);

        expect(licenseName.querySelector('a').getAttribute('href')).toBe('about:blank');
        expect(licenseName.querySelector('a').innerText).toBe(badURL);
      })
      .then(done)
      .catch(done.fail);
  });
});
