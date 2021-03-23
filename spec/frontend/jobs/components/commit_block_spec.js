import { shallowMount } from '@vue/test-utils';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';
import CommitBlock from '~/jobs/components/commit_block.vue';
import ClipboardButton from '~/vue_shared/components/clipboard_button.vue';

describe('Commit block', () => {
  let wrapper;

  const defaults = {
    commit: {
      short_id: '1f0fb84f',
      id: '1f0fb84fb6770d74d97eee58118fd3909cd4f48c',
      commit_path: 'commit/1f0fb84fb6770d74d97eee58118fd3909cd4f48c',
      title: 'Update README.md',
    },
    mergeRequest: {
      iid: '!21244',
      path: 'merge_requests/21244',
    },
    isLastBlock: true,
  };

  const findCommitSha = () => wrapper.findByTestId('commit-sha');
  const findLinkSha = () => wrapper.findByTestId('link-commit');

  function mountComponent(props = {}) {
    wrapper = extendedWrapper(
      shallowMount(CommitBlock, {
        propsData: {
          ...props,
        },
      }),
    );
  }

  afterEach(() => {
    wrapper.destroy();
  });

  describe('pipeline short sha', () => {
    beforeEach(() => {
      mountComponent(defaults);
    });

    it('renders pipeline short sha link', () => {
      expect(findCommitSha().attributes('href')).toBe(defaults.commit.commit_path);
      expect(findCommitSha().text()).toBe(defaults.commit.short_id);
    });

    it('renders clipboard button', () => {
      expect(wrapper.findComponent(ClipboardButton).attributes('text')).toBe(defaults.commit.id);
    });
  });

  describe('with merge request', () => {
    it('renders merge request link and reference', () => {
      mountComponent(defaults);

      expect(findLinkSha().attributes('href')).toBe(defaults.mergeRequest.path);
      expect(findLinkSha().text()).toBe(`!${defaults.mergeRequest.iid}`);
    });
  });

  describe('without merge request', () => {
    it('does not render merge request', () => {
      const copyProps = { ...defaults };
      delete copyProps.mergeRequest;

      mountComponent(copyProps);

      expect(findLinkSha().exists()).toBe(false);
    });
  });

  describe('git commit title', () => {
    it('renders git commit title', () => {
      mountComponent(defaults);

      expect(wrapper.text()).toContain(defaults.commit.title);
    });
  });
});
