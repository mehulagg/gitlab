import Vue, { nextTick } from 'vue';
import { initSecurityConfiguration } from 'ee/security_configuration';
import { resetHTMLFixture } from 'helpers/fixtures';
import { someEnabledEl, noneEnabledEl, someEnabledWithAutoDevOpsEl } from './mock_data';

const errorsAndWarnings = [];

const errorWarnHandler = (error, vm, info) => {
  errorsAndWarnings.push(`Vue error/warning: Message: ${error}

vm.name: ${vm.name}
info: ${JSON.stringify(info)}
  `);
};

Vue.config.errorHandler = errorWarnHandler;
Vue.config.warnHandler = errorWarnHandler;

describe('Security Configuration App', () => {
  describe.each`
    context                                | mountElHtml
    ${'some enabled scanners (gitlab-ui)'} | ${someEnabledEl}
    ${'no enabled scanners'}               | ${noneEnabledEl}
    ${'some enabled by ADO'}               | ${someEnabledWithAutoDevOpsEl}
  `('given $context', ({ mountElHtml }) => {
    beforeEach(() => {
      setFixtures(mountElHtml);

      const el = document.querySelector('#js-security-configuration');
      initSecurityConfiguration(el);

      return nextTick();
    });

    afterEach(() => {
      resetHTMLFixture();
    });

    it('matches the snapshot', () => {
      expect(errorsAndWarnings).toEqual([]);
      expect(document.body).toMatchSnapshot();
    });
  });
});
