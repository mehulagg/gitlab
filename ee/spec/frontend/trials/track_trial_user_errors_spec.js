import trackTrialUserErrors from 'ee/trials/track_trial_user_errors';
import { mockTracking } from 'helpers/tracking_helper';

describe('trackTrialUserErrors', () => {
  let spy;

  describe('when an error is present', () => {
    const errorMessage = 'You cannot have multiple trials';

    beforeEach(() => {
      document.body.innerHTML = `
      <div class="flash-container trial-errors"
        .<div class="flash-alert.text-center">
            We have found the following errors:
            <div class="flash-text">
              ${errorMessage}
           </div>
         </div>
      </div>
    `;
      spy = mockTracking('trials:create', document.body, jest.spyOn);
    });

    it('tracks the error message', () => {
      trackTrialUserErrors();

      expect(spy).toHaveBeenCalledWith('trials:create', 'create_trial_error', {
        label: 'flash-text',
        property: 'message',
        value: errorMessage,
      });
    });

    it('tracks the error message when snowplow is initialized', () => {
      document.dispatchEvent(new Event('SnowplowInitialized'));

      expect(spy).toHaveBeenCalledWith('trials:create', 'create_trial_error', {
        label: 'flash-text',
        property: 'message',
        value: errorMessage,
      });
    });
  });

  describe('when no error is present', () => {
    beforeEach(() => {
      document.body.innerHTML = `
        <div id="dummy-wrapper-element">
        </div>
    `;
    });

    it('does not track the any error message', () => {
      trackTrialUserErrors();

      expect(spy).not.toHaveBeenCalled();
    });
  });
});
