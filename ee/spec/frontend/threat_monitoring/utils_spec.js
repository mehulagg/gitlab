import { getContentWrapperHeight } from 'ee/threat_monitoring/utils';
import { setHTMLFixture } from 'helpers/fixtures';

describe('Threat Monitoring Utils', () => {
  describe('getContentWrapperHeight', () => {
    const fixture = `
      <div>
        <div class="content-wrapper">
          <div class="content"></div>
        </div>
      </div>
    `;

    beforeEach(() => {
      setHTMLFixture(fixture);
    });

    it('returns the height of an element that exists', () => {
      expect(getContentWrapperHeight('.content-wrapper')).toBe('0px');
    });

    it('returns an empty string for a class that does not exist', () => {
      expect(getContentWrapperHeight('.does-not-exist')).toBe('');
    });
  });
});
