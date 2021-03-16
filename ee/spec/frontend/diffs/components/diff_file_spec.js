import { shallowMount, createLocalVue } from '@vue/test-utils';
import Vuex from 'vuex';

import diffFileMockDataReadable from 'jest/diffs/mock_data/diff_file';
import DiffFileComponent from '~/diffs/components/diff_file.vue';

import createDiffsStore from '~/diffs/store/modules';

function createComponent({ file, first = false, last = false, options = {}, props = {} }) {
  const localVue = createLocalVue();

  localVue.use(Vuex);

  const store = new Vuex.Store({
    modules: {
      diffs: createDiffsStore(),
    },
  });

  store.state.diffs.diffFiles = [file];

  const wrapper = shallowMount(DiffFileComponent, {
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

const getReadableFile = () => JSON.parse(JSON.stringify(diffFileMockDataReadable));

describe('EE DiffFile', () => {
  let wrapper;
  let store;

  beforeEach(() => {
    ({ wrapper, store } = createComponent({
      file: getReadableFile(),
    }));
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('computed', () => {
    describe('hasCodequalityChanges', () => {
      it('is true when there is diff data for the file', () => {
        ({ wrapper } = createComponent({
          props: {
            file: store.state.diffs.diffFiles[0],
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

        expect(wrapper.vm.hasCodequalityChanges).toEqual(true);
      });

      it('is false when there is no diff data for the file', () => {
        ({ wrapper } = createComponent({
          props: {
            file: store.state.diffs.diffFiles[0],
          },
        }));

        expect(wrapper.vm.hasCodequalityChanges).toEqual(false);
      });
    });
  });
});
