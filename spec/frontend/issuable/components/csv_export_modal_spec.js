import { GlModal, GlIcon, GlButton, GlSprintf } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';
import CsvExportModal from '~/issuable/components/csv_export_modal.vue';

describe('CsvExportModal', () => {
  let wrapper;

  function createComponent(options = {}) {
    const { injectedProperties = {}, props = {} } = options;
    return extendedWrapper(
      shallowMount(CsvExportModal, {
        propsData: {
          modalId: 'csv-export-modal',
          ...props,
        },
        provide: {
          issuableType: 'issues',
          ...injectedProperties,
        },
        stubs: {
          GlModal,
          GlSprintf,
        },
      }),
    );
  }

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  const findModal = () => wrapper.find(GlModal);
  const findIcon = () => wrapper.find(GlIcon);
  const findButton = () => wrapper.find(GlButton);

  describe('template', () => {
    describe.each`
      issuableType        | modalTitle
      ${'issues'}         | ${'Export issues'}
      ${'merge-requests'} | ${'Export merge requests'}
    `('with the issuableType "$issuableType"', ({ issuableType, modalTitle }) => {
      beforeEach(() => {
        wrapper = createComponent({ injectedProperties: { issuableType } });
      });

      it('displays the modal title "$modalTitle"', () => {
        expect(findModal().text()).toContain(modalTitle);
      });

      it('displays the button with title "$modalTitle"', () => {
        expect(findButton().text()).toBe(modalTitle);
      });
    });

    describe('issuable count info text', () => {
      it('displays the info text when issuableCount is > -1', () => {
        wrapper = createComponent({ injectedProperties: { issuableCount: 10 } });
        expect(wrapper.findByTestId('issuable-count-note').exists()).toBe(true);
        expect(wrapper.findByTestId('issuable-count-note').text()).toContain('10 issues selected');
        expect(findIcon().exists()).toBe(true);
      });

      it("doesn't display the info text when issuableCount is -1", () => {
        wrapper = createComponent({ injectedProperties: { issuableCount: -1 } });
        expect(wrapper.findByTestId('issuable-count-note').exists()).toBe(false);
      });
    });

    describe('email info text', () => {
      it('displays the proper email', () => {
        const email = 'admin@example.com';
        wrapper = createComponent({ injectedProperties: { email } });
        expect(findModal().text()).toContain(
          `The CSV export will be created in the background. Once finished, it will be sent to ${email} in an attachment.`,
        );
      });
    });

    describe('primary button', () => {
      it('passes the exportCsvPath to the button', () => {
        const exportCsvPath = '/gitlab-org/gitlab-test/-/issues/export_csv';
        wrapper = createComponent({ injectedProperties: { exportCsvPath } });
        expect(findButton().attributes('href')).toBe(exportCsvPath);
      });
    });
  });
});
