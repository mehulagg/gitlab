import { GlButton } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import AxiosMockAdapter from 'axios-mock-adapter';
import CreateMergeRequestButton from 'ee/security_configuration/components/create_merge_request_button.vue';
import waitForPromises from 'helpers/wait_for_promises';
import { deprecatedCreateFlash as createFlash } from '~/flash';
import axios from '~/lib/utils/axios_utils';
import { redirectTo } from '~/lib/utils/url_utility';
import * as Sentry from '~/sentry/wrapper';

jest.mock('~/flash.js');
jest.mock('~/lib/utils/url_utility', () => ({
  redirectTo: jest.fn(),
}));

const endpoint = '/endpoint';
const { i18n } = CreateMergeRequestButton;
const DEFAULT_BUTTON_PROPS = {
  category: 'primary',
  variant: 'default',
};
const SUCCESS_BUTTON_PROPS = {
  category: 'primary',
  variant: 'success',
};
const MERGE_REQUEST_PATH = '/merge_requests/new';

describe('CreateMergeRequestButton component', () => {
  let axiosMock;
  let wrapper;

  const createComponent = (props = {}) => {
    wrapper = shallowMount(CreateMergeRequestButton, {
      propsData: {
        endpoint,
        autoDevopsEnabled: false,
        ...props,
      },
    });
  };

  beforeEach(() => {
    axiosMock = new AxiosMockAdapter(axios);
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
    axiosMock.restore();
  });

  const findButton = () => wrapper.find(GlButton);

  describe.each`
    autoDevopsEnabled | buttonText           | buttonProps
    ${false}          | ${i18n.noAutoDevOps} | ${SUCCESS_BUTTON_PROPS}
    ${true}           | ${i18n.autoDevOps}   | ${DEFAULT_BUTTON_PROPS}
  `(
    'when autoDevopsEnabled is $autoDevopsEnabled',
    ({ autoDevopsEnabled, buttonText, buttonProps }) => {
      beforeEach(() => {
        createComponent({ autoDevopsEnabled });
      });

      it('uses the right button label', () => {
        expect(findButton().text()).toEqual(buttonText);
      });

      it('passes the correct data to the button', () => {
        expect(findButton().props()).toMatchObject({
          loading: false,
          ...buttonProps,
        });
      });
    },
  );

  describe('when clicking the button', () => {
    describe.each`
      context                    | filePath              | statusCode | partialErrorMessage
      ${'a response error code'} | ${MERGE_REQUEST_PATH} | ${500}     | ${'500'}
      ${'no filePath'}           | ${''}                 | ${200}     | ${/merge request.*fail/}
    `(
      'given an unsuccessful endpoint response due to $context',
      ({ filePath, statusCode, partialErrorMessage }) => {
        beforeEach(() => {
          axiosMock.onPost(endpoint).replyOnce(statusCode, { filePath });
          jest.spyOn(Sentry, 'captureException').mockImplementation();
          createComponent();

          findButton().vm.$emit('click');
        });

        it('sets the loading prop to true', () => {
          expect(findButton().props().loading).toBe(true);
        });

        describe('after async tasks', () => {
          beforeEach(() => waitForPromises());

          it('does not call redirectTo', () => {
            expect(redirectTo).not.toHaveBeenCalled();
          });

          it('creates a flash message', () => {
            expect(createFlash).toHaveBeenCalledWith(expect.any(String));
          });

          it('sends the error to Sentry', () => {
            expect(Sentry.captureException.mock.calls).toMatchObject([
              [{ message: expect.stringMatching(partialErrorMessage) }],
            ]);
          });

          it('sets the loading prop to false', () => {
            expect(findButton().props().loading).toBe(false);
          });
        });
      },
    );

    describe('given a successful endpoint response', () => {
      beforeEach(() => {
        axiosMock.onPost(endpoint).replyOnce(200, { filePath: MERGE_REQUEST_PATH });
        jest.spyOn(Sentry, 'captureException').mockImplementation();
        createComponent();

        findButton().vm.$emit('click');
      });

      it('sets the loading prop to true', () => {
        expect(findButton().props().loading).toBe(true);
      });

      describe('after async tasks', () => {
        beforeEach(() => waitForPromises());

        it('calls redirectTo', () => {
          expect(redirectTo).toHaveBeenCalledWith(MERGE_REQUEST_PATH);
        });

        it('does not create a flash message', () => {
          expect(createFlash).not.toHaveBeenCalled();
        });

        it('does not call Sentry.captureException', () => {
          expect(Sentry.captureException).not.toHaveBeenCalled();
        });

        it('keeps the loading prop set to true', () => {
          // This is done for UX reasons. If the loading prop is set to false
          // on success, then there's a period where the button is clickable
          // again. Instead, we want the button to display a loading indicator
          // for the remainder of the lifetime of the page (i.e., until the
          // browser can start painting the new page it's been redirected to).
          expect(findButton().props().loading).toBe(true);
        });
      });
    });
  });
});
