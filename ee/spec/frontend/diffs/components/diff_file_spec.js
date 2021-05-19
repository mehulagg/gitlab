import { mount, createLocalVue } from '@vue/test-utils';
import Vuex from 'vuex';

import CodeQualityBadge from 'ee/diffs/components/code_quality_badge.vue';
import diffFileMockDataReadable from 'jest/diffs/mock_data/diff_file';
import DiffFileComponent from '~/diffs/components/diff_file.vue';

import createDiffsStore from '~/diffs/store/modules';

const getReadableFile = () => JSON.parse(JSON.stringify(diffFileMockDataReadable));

function createComponent({ withCodequality = true, provide = {} }) {
  const file = getReadableFile();
  const localVue = createLocalVue();

  localVue.use(Vuex);

  const store = new Vuex.Store({
    modules: {
      diffs: createDiffsStore(),
    },
  });

  store.state.diffs.diffFiles = [file];

  if (withCodequality) {
    store.state.diffs.codequalityDiff = {
      files: {
        [file.file_path]: [
          { line: 1, description: 'Unexpected alert.', severity: 'minor' },
          {
            line: 3,
            description: 'Arrow function has too many statements (52). Maximum allowed is 30.',
            severity: 'minor',
          },
        ],
      },
    };
  }

  const wrapper = mount(DiffFileComponent, {
    store,
    localVue,
    propsData: {
      file,
      canCurrentUserFork: false,
      viewDiffsFileByFile: false,
      isFirstFile: false,
      isLastFile: false,
    },
    provide,
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
        ({ wrapper } = createComponent({ withCodequality: true }));
      });

      it('shows the code quality badge', () => {
        expect(wrapper.find(CodeQualityBadge).exists()).toBe(true);
      });
    });

    describe('when the feature flag for the next iteration is enabled', () => {
      beforeEach(() => {
        ({ wrapper } = createComponent({
          withCodequality: true,
          provide: { glFeatures: { codequalityMrDiffAnnotations: true } },
        }));
      });

      it('does not show the code quality badge', () => {
        expect(wrapper.find(CodeQualityBadge).exists()).toBe(false);
      });
    });

    describe('when there is no diff data for the file', () => {
      beforeEach(() => {
        ({ wrapper } = createComponent({ withCodequality: false }));
      });

      it('does not show the code quality badge', () => {
        expect(wrapper.find(CodeQualityBadge).exists()).toBe(false);
      });
    });
  });
});
