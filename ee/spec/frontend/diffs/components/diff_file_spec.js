import { mount, createLocalVue } from '@vue/test-utils';
import Vuex from 'vuex';

import CodeQualityBadge from 'ee/diffs/components/code_quality_badge.vue';
import diffFileMockDataReadable from 'jest/diffs/mock_data/diff_file';
import DiffFileComponent from '~/diffs/components/diff_file.vue';

import createDiffsStore from '~/diffs/store/modules';

const getReadableFile = () => JSON.parse(JSON.stringify(diffFileMockDataReadable));

function createComponent({ first = false, last = false, options = {}, props = {} }) {
  const file = getReadableFile();
  const localVue = createLocalVue();

  localVue.use(Vuex);

  const store = new Vuex.Store({
    modules: {
      diffs: createDiffsStore(),
    },
  });

  store.state.diffs.diffFiles = [file];

  const wrapper = mount(DiffFileComponent, {
    store,
    localVue,
    propsData: {
      file,
      canCurrentUserFork: false,
      viewDiffsFileByFile: false,
      isFirstFile: first,
      isLastFile: last,
      ...props,
    },
    ...options,
  });

  return {
    localVue,
    wrapper,
    store,
  };
}

describe('EE DiffFile', () => {
  let wrapper;

  afterEach(() => {
    wrapper.destroy();
  });

  describe('code quality badge', () => {
    describe('when there is diff data for the file', () => {
      beforeEach(() => {
        ({ wrapper } = createComponent({
          props: {
            codequalityDiff: [
              { line: 1, description: 'Unexpected alert.', severity: 'minor' },
              {
                line: 3,
                description: 'Arrow function has too many statements (52). Maximum allowed is 30.',
                severity: 'minor',
              },
            ],
          },
        }));
      });

      it('shows the code quality badge', () => {
        expect(wrapper.find(CodeQualityBadge).exists()).toBe(true);
      });
    });

    describe('when there is no diff data for the file', () => {
      beforeEach(() => {
        ({ wrapper } = createComponent({}));
      });

      it('does not show the code quality badge', () => {
        expect(wrapper.find(CodeQualityBadge).exists()).toBe(false);
      });
    });
  });
});
