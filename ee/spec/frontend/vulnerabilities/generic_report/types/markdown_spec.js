import { GlLoadingIcon } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import MockAdapter from 'axios-mock-adapter';
import Markdown from 'ee/vulnerabilities/components/generic_report/types/markdown.vue';
import axios from '~/lib/utils/axios_utils';
import httpStatusCodes from '~/lib/utils/http_status';

const MARKDOWN = 'Checkout [GitLab](http://gitlab.com)';
const RENDERED_MARKDOWN =
  '\u003cp data-sourcepos="1:1-1:36" dir="auto"\u003eCheckout \u003ca href="http://gitlab.com"\u003eGitLab\u003c/a\u003e\u003c/p\u003e';

describe('ee/vulnerabilities/components/generic_report/types/markdown.vue', () => {
  let wrapper;
  let mock;

  const createWrapper = () => {
    return shallowMount(Markdown, {
      propsData: {
        value: MARKDOWN,
      },
    });
  };

  const findLoadingIcon = () => wrapper.findComponent(GlLoadingIcon);
  const findMarkdown = () => wrapper.find('[data-testid="markdown"]');

  const setUpMockMarkdown = () => {
    mock
      .onPost('/api/v4/markdown', {
        text: MARKDOWN,
        gfm: true,
      })
      .replyOnce(httpStatusCodes.OK, { html: RENDERED_MARKDOWN });
  };

  beforeEach(() => {
    mock = new MockAdapter(axios);

    setUpMockMarkdown();

    wrapper = createWrapper({});
  });

  afterEach(() => {
    mock.restore();
    wrapper.destroy();
  });

  describe('when loading', () => {
    it('shows the loading icon', async () => {
      await wrapper.setData({ loading: true });
      expect(findLoadingIcon().exists()).toBe(true);
    });
  });

  describe('when loaded', () => {
    it('shows markdown', async () => {
      await axios.waitForAll();
      expect(findLoadingIcon().exists()).toBe(false);
      expect(findMarkdown().element.innerHTML).toBe(RENDERED_MARKDOWN);
    });
  });
});
