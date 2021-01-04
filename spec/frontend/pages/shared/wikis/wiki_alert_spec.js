import { GlAlert, GlLink, GlSprintf } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import WikiAlert from '~/pages/shared/wikis/components/wiki_alert.vue';
import { ERRORS } from '~/pages/shared/wikis/constants';

describe('WikiAlert', () => {
  let wrapper;

  function createWrapper(propsData = {}, stubs = {}) {
    wrapper = shallowMount(WikiAlert, {
      propsData,
      stubs,
    });
  }

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  const findGlAlert = () => wrapper.findComponent(GlAlert);
  const findGlLink = () => wrapper.findComponent(GlLink);
  const findGlSprintf = () => wrapper.findComponent(GlSprintf);

  describe('Wiki Alert', () => {
    it('does show an alert when there is an error', () => {
      createWrapper({ error: ERRORS.PAGE_RENAME.ERROR });
      expect(findGlAlert().exists()).toBe(true);
    });

    it('does not show an alert when there is an error', () => {
      createWrapper();
      expect(findGlAlert().exists()).toBe(false);
    });

    it('does show the page change message text', () => {
      createWrapper({ error: ERRORS.PAGE_CHANGE.ERROR });
      expect(findGlSprintf().exists()).toBe(true);
      const text = findGlSprintf();
      expect(text.attributes('message')).toBe(ERRORS.PAGE_CHANGE.MESSAGE);
    });

    it('does show the page rename message text', () => {
      createWrapper({ error: ERRORS.PAGE_RENAME.ERROR });
      expect(findGlSprintf().attributes('message')).toBe(ERRORS.PAGE_RENAME.MESSAGE);
    });

    it('does show the error message', () => {
      const error = 'test message';
      createWrapper({ error });
      expect(findGlSprintf().attributes('message')).toBe(error);
    });

    it('does show the link to the help path', () => {
      const wikiPagePath = '/help';
      createWrapper({ error: ERRORS.PAGE_CHANGE.ERROR, wikiPagePath }, { GlAlert, GlSprintf });
      expect(findGlLink().attributes('href')).toBe(wikiPagePath);
    });
  });
});
