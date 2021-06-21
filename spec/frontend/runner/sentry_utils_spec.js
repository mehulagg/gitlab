import * as Sentry from '@sentry/browser';
import { reportToSentry } from '~/runner/sentry_utils';

jest.mock('@sentry/browser');

describe('~/runner/sentry_utils', () => {
  let mockSetTag;

  beforeEach(async () => {
    mockSetTag = jest.fn();

    Sentry.withScope.mockImplementation((fn) => {
      const scope = { setTag: mockSetTag };
      fn(scope);
    });
  });

  describe('reportToSentry', () => {
    const mockError = new Error('Something went wrong!');

    it('error is reported to sentry', () => {
      reportToSentry({ error: mockError });

      expect(Sentry.withScope).toHaveBeenCalled();
      expect(Sentry.captureException).toHaveBeenCalledWith(mockError);
    });

    it('error is reported to sentry with a component name', () => {
      const mockComponentName = 'my_component';

      reportToSentry({ error: mockError, component: mockComponentName });

      expect(Sentry.withScope).toHaveBeenCalled();
      expect(Sentry.captureException).toHaveBeenCalledWith(mockError);

      expect(mockSetTag).toHaveBeenCalledWith('component', mockComponentName);
    });
  });
});
