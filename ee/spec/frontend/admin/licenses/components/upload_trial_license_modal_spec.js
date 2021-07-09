import { GlModal } from '@gitlab/ui';
import UploadTrialLicenseModal from 'ee/admin/licenses/components/upload_trial_license_modal.vue';
import { stubComponent } from 'helpers/stub_component';
import { mountExtended } from 'helpers/vue_test_utils_helper';

jest.mock('~/lib/utils/csrf', () => ({ token: 'mock-csrf-token' }));

describe('UploadTrialLicenseModal', () => {
  let wrapper;
  let formSubmitSpy;

  function createComponent(props = {}) {
    return mountExtended(UploadTrialLicenseModal, {
      propsData: {
        initialShow: true,
        ...props,
      },
      stubs: {
        GlModal: stubComponent(GlModal, {
          template: '<div><slot></slot><slot name="modal-footer"></slot></div>',
        }),
      },
    });
  }

  beforeEach(() => {
    formSubmitSpy = jest.spyOn(HTMLFormElement.prototype, 'submit').mockImplementation();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  const findModal = () => wrapper.findComponent(GlModal);
  const findForm = () => wrapper.find('form');
  const findAuthenticityToken = () => new FormData(findForm().element).get('authenticity_token');
  const findLicenseData = () => new FormData(findForm().element).get('license[data]');

  describe('template', () => {
    const licenseKey = '12345abcde';
    const adminLicensePath = '/admin/license';

    describe('form', () => {
      beforeEach(() => {
        wrapper = createComponent({ licenseKey, adminLicensePath });
      });

      it('displays the form with the correct action and inputs', () => {
        expect(findForm().exists()).toBe(true);
        expect(findForm().attributes('action')).toBe(adminLicensePath);
        expect(findAuthenticityToken()).toBe('mock-csrf-token');
        expect(findLicenseData()).toBe(licenseKey);
      });

      it('submits the form when the primary action is clicked', () => {
        const mockEvent = { preventDefault: jest.fn() };
        findModal().vm.$emit('primary', mockEvent);

        expect(formSubmitSpy).toHaveBeenCalled();
      });
    });
  });
});
