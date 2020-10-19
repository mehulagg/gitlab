import Vue from 'vue';
import Vuex from 'vuex';

import DeleteConfirmationModal from 'ee/vue_shared/license_compliance/components/delete_confirmation_modal.vue';
import { trimText } from 'helpers/text_helper';
import { mountComponentWithStore } from 'helpers/vue_mount_component_helper';
import { approvedLicense } from '../mock_data';

Vue.use(Vuex);

describe('DeleteConfirmationModal', () => {
  const Component = Vue.extend(DeleteConfirmationModal);
  let vm;
  let store;
  let actions;

  beforeEach(() => {
    actions = {
      resetLicenseInModal: jest.fn(),
      deleteLicense: jest.fn(),
    };

    store = new Vuex.Store({
      modules: {
        licenseManagement: {
          namespaced: true,
          state: {
            currentLicenseInModal: approvedLicense,
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

  describe('computed', () => {
    describe('confirmationText', () => {
      it('returns information text with current license name in bold', () => {
        expect(vm.confirmationText).toBe(
          `You are about to remove the license, <strong>${approvedLicense.name}</strong>, from this project.`,
        );
      });

      it('escapes the license name', done => {
        const name = '<a href="#">BAD</a>';
        const nameEscaped = '&lt;a href=&quot;#&quot;&gt;BAD&lt;/a&gt;';

        store.replaceState({
          ...store.state,
          licenseManagement: {
            currentLicenseInModal: {
              ...approvedLicense,
              name,
            },
          },
        });

        Vue.nextTick()
          .then(() => {
            expect(vm.confirmationText).toBe(
              `You are about to remove the license, <strong>${nameEscaped}</strong>, from this project.`,
            );
          })
          .then(done)
          .catch(done.fail);
      });
    });
  });

  describe('interaction', () => {
    describe('triggering resetLicenseInModal on canceling', () => {
      it('by clicking the cancel button', () => {
        const linkEl = vm.$el.querySelector('.js-modal-cancel-action');
        linkEl.click();

        expect(actions.resetLicenseInModal).toHaveBeenCalled();
      });

      it('by clicking the X button', () => {
        const linkEl = vm.$el.querySelector('.js-modal-close-action');
        linkEl.click();

        expect(actions.resetLicenseInModal).toHaveBeenCalled();
      });
    });

    describe('triggering deleteLicense on canceling', () => {
      it('by clicking the confirmation button', () => {
        const linkEl = vm.$el.querySelector('.js-modal-primary-action');
        linkEl.click();

        expect(actions.deleteLicense).toHaveBeenCalledWith(
          expect.any(Object),
          store.state.licenseManagement.currentLicenseInModal,
        );
      });
    });
  });

  describe('template', () => {
    it('renders modal title', () => {
      const headerEl = vm.$el.querySelector('.modal-title');

      expect(headerEl).not.toBeNull();
      expect(headerEl.innerText.trim()).toBe('Remove license?');
    });

    it('renders button in modal footer', () => {
      const footerButton = vm.$el.querySelector('.js-modal-primary-action');

      expect(footerButton).not.toBeNull();
      expect(footerButton.innerText.trim()).toBe('Remove license');
    });

    it('renders modal body', () => {
      const modalBody = vm.$el.querySelector('.modal-body');

      expect(modalBody).not.toBeNull();
      expect(trimText(modalBody.innerText)).toBe(
        `You are about to remove the license, ${approvedLicense.name}, from this project.`,
      );
    });
  });
});
