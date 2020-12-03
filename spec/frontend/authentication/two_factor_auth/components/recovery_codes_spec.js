import { mount } from '@vue/test-utils';
import { GlAlert, GlButton } from '@gitlab/ui';
import { nextTick } from 'vue';
import { within } from '@testing-library/dom';
import { extendedWrapper } from 'jest/helpers/vue_test_utils_helper';
import RecoveryCodes, {
  i18n,
} from '~/authentication/two_factor_auth/components/recovery_codes.vue';
import ClipboardButton from '~/vue_shared/components/clipboard_button.vue';
import { RECOVERY_CODE_DOWNLOAD_FILENAME } from '~/authentication/two_factor_auth/constants';
import { codes, codesFormattedString, codesDownloadHref, profileAccountPath } from '../mock_data';

describe('RecoveryCodes', () => {
  let wrapper;

  const createComponent = (options = {}) => {
    wrapper = extendedWrapper(
      mount(RecoveryCodes, {
        propsData: {
          codes,
          profileAccountPath,
          ...(options?.propsData || {}),
        },
        ...options,
      }),
    );
  };

  const queryByText = (text, options) => within(wrapper.element).queryByText(text, options);
  const findAlert = () => wrapper.find(GlAlert);
  const findRecoveryCodes = () => wrapper.findByTestId('recovery-codes');
  const findCopyButton = () => wrapper.find(ClipboardButton);
  const findButtonByText = text =>
    wrapper.findAll(GlButton).wrappers.find(buttonWrapper => buttonWrapper.text() === text);
  const findDownloadButton = () => findButtonByText('Download codes');
  const findPrintButton = () => findButtonByText('Print codes');
  const findProceedButton = () => findButtonByText('Proceed');

  beforeEach(() => {
    createComponent();
  });

  it('renders title', () => {
    expect(queryByText(i18n.pageTitle)).not.toBe(null);
  });

  it('renders alert', () => {
    expect(findAlert().exists()).toBe(true);
    expect(findAlert().text()).toBe(i18n.alertTitle);
  });

  it('renders codes in list', () => {
    const codeWrappers = findRecoveryCodes().findAll('li');

    codeWrappers.wrappers.forEach((code, index) => {
      expect(code.text()).toBe(codes[index]);
    });
  });

  describe('"Proceed" button', () => {
    it('renders button as disabled', () => {
      const proceedButton = findProceedButton();

      expect(proceedButton.exists()).toBe(true);
      expect(proceedButton.props('disabled')).toBe(true);
      expect(proceedButton.attributes()).toMatchObject({
        title: i18n.proceedButton,
        href: profileAccountPath,
      });
    });
  });

  describe('"Copy codes" button', () => {
    it('renders button', () => {
      const copyButton = findCopyButton();

      expect(copyButton.exists()).toBe(true);
      expect(copyButton.text()).toBe(i18n.copyButton);
      expect(copyButton.props()).toMatchObject({
        title: i18n.copyButton,
        text: codesFormattedString,
      });
    });

    describe('when button is clicked', () => {
      it('enables "Proceed" button', async () => {
        findCopyButton().trigger('click');

        await nextTick();

        expect(findProceedButton().props('disabled')).toBe(false);
      });
    });
  });

  describe('"Download codes" button', () => {
    it('renders button', () => {
      const downloadButton = findDownloadButton();

      expect(downloadButton.exists()).toBe(true);
      expect(downloadButton.attributes()).toMatchObject({
        title: i18n.downloadButton,
        download: RECOVERY_CODE_DOWNLOAD_FILENAME,
        href: codesDownloadHref,
      });
    });

    describe('when button is clicked', () => {
      it('enables "Proceed" button', async () => {
        const downloadButton = findDownloadButton();
        // jsdom does not support navigating.
        // Since we are clicking an anchor tag there is now way to mock this
        // and we are forced to instead remove the `href` attribute.
        // More info: https://github.com/jsdom/jsdom/issues/2112#issuecomment-663672587
        downloadButton.element.removeAttribute('href');
        downloadButton.trigger('click');

        await nextTick();

        expect(findProceedButton().props('disabled')).toBe(false);
      });
    });
  });

  describe('"Print codes" button', () => {
    it('renders button', () => {
      const printButton = findPrintButton();

      expect(printButton.exists()).toBe(true);
      expect(printButton.attributes()).toMatchObject({
        title: i18n.printButton,
      });
    });

    describe('when button is clicked', () => {
      it('enables "Proceed" button and opens print dialog', async () => {
        window.print = jest.fn();

        findPrintButton().trigger('click');

        await nextTick();

        expect(findProceedButton().props('disabled')).toBe(false);
        expect(window.print).toHaveBeenCalledWith();
      });
    });
  });

  describe('when codes are manually copied', () => {
    describe('when selected text is the recovery codes', () => {
      beforeEach(() => {
        jest.spyOn(window, 'getSelection').mockImplementation(() => ({
          toString: jest.fn(() => codesFormattedString),
        }));
      });

      afterEach(() => {
        jest.restoreAllMocks();
      });

      it('enables "Proceed" button', async () => {
        wrapper.vm.$options.mousetrap.trigger('meta+c');

        await nextTick();

        expect(findProceedButton().props('disabled')).toBe(false);
      });
    });

    describe('when selected text is not the recovery codes', () => {
      it('keeps "Proceed" button disabled', async () => {
        wrapper.vm.$options.mousetrap.trigger('meta+c');

        await nextTick();

        expect(findProceedButton().props('disabled')).toBe(true);
      });
    });
  });
});
