import { createWrapper } from '@vue/test-utils';
import { getByTestId, fireEvent } from '@testing-library/dom';
import * as urlUtils from '~/lib/utils/url_utility';
import { initRecoveryCodes, initClose2faSuccessMessage } from '~/authentication/two_factor_auth';
import RecoveryCodes from '~/authentication/two_factor_auth/components/recovery_codes.vue';
import { codesJsonString, codes, profileAccountPath } from './mock_data';

describe('initRecoveryCodes', () => {
  let el;
  let wrapper;

  const findRecoveryCodesComponent = () => wrapper.find(RecoveryCodes);

  beforeEach(() => {
    el = document.createElement('div');
    el.setAttribute('class', 'js-2fa-recovery-codes');
    el.setAttribute('data-codes', codesJsonString);
    el.setAttribute('data-profile-account-path', profileAccountPath);
    document.body.appendChild(el);

    wrapper = createWrapper(initRecoveryCodes());
  });

  afterEach(() => {
    document.body.innerHTML = '';
  });

  it('parses `data-codes` and passes to `RecoveryCodes` as `codes` prop', () => {
    expect(findRecoveryCodesComponent().props('codes')).toEqual(codes);
  });

  it('parses `data-profile-account-path` and passes to `RecoveryCodes` as `profileAccountPath` prop', () => {
    expect(findRecoveryCodesComponent().props('profileAccountPath')).toEqual(profileAccountPath);
  });
});

describe('initClose2faSuccessMessage', () => {
  beforeEach(() => {
    document.body.innerHTML = `
      <div
        class="gl-alert gl-alert-success gl-my-5"
        role="alert"
      >
        <svg
          class="s16 gl-alert-icon gl-alert-icon-no-title"
          data-testid="check-circle-icon"
        >
          <use
            xlink:href="/assets/icons-e0a66cb8e6ca64bcdd2a8f111cbd9e94cf727c1bd5939bc71619df5c973fbc87.svg#check-circle"
          ></use>
        </svg>
        <button
          aria-label="Close"
          data-testid="close-2fa-enabled-success-alert"
          class="gl-alert-dismiss js-close js-close-2fa-enabled-success-alert"
          type="button"
        >
          <svg class="s16" data-testid="close-icon">
            <use
              xlink:href="/assets/icons-e0a66cb8e6ca64bcdd2a8f111cbd9e94cf727c1bd5939bc71619df5c973fbc87.svg#close"
            ></use>
          </svg>
        </button>
        <div class="gl-alert-body">
          Congratulations! You have enabled Two-factor Authentication!
        </div>
      </div>
    `;

    initClose2faSuccessMessage();
  });

  afterEach(() => {
    document.body.innerHTML = '';
  });

  describe('when alert is closed', () => {
    beforeEach(() => {
      delete window.location;
      window.location = new URL(
        'https://localhost/-/profile/account?two_factor_auth_enabled_successfully=true',
      );

      document.title = 'foo bar';

      urlUtils.updateHistory = jest.fn();
    });

    afterEach(() => {
      document.title = '';
    });

    it('removes `two_factor_auth_enabled_successfully` query param', () => {
      fireEvent.click(getByTestId(document.body, 'close-2fa-enabled-success-alert'));

      expect(urlUtils.updateHistory).toHaveBeenCalledWith({
        url: 'https://localhost/-/profile/account',
        title: 'foo bar',
        replace: true,
      });
    });
  });
});
