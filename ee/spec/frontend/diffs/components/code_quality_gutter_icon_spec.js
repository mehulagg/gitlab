import { GlIcon } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import Vue from 'vue';
import Vuex from 'vuex';
import CodeQualityGutterIcon from 'ee/diffs/components/code_quality_gutter_icon.vue';
import createDiffsStore from 'jest/diffs/create_diffs_store';
import { SEVERITY_CLASSES, SEVERITY_ICONS } from '~/reports/codequality_report/constants';

Vue.use(Vuex);

describe('EE CodeQualityGutterIcon', () => {
  let store;
  let wrapper;
  let codequalityDiff;

  const findIcon = () => wrapper.findComponent(GlIcon);

  const createComponent = (props = {}, extendStore = () => {}) => {
    store = createDiffsStore();
    store.state.diffs.codequalityDiff = codequalityDiff;

    extendStore(store);

    wrapper = shallowMount(CodeQualityGutterIcon, {
      propsData: {
        filePath: 'index.js',
        line: {
          left: {},
          right: {},
        },
        ...props,
      },
      store,
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  describe('with violations on some lines', () => {
    codequalityDiff = {
      files: {
        'index.js': [
          {
            severity: 'minor',
            description: 'Unexpected alert.',
            line: 1,
          },
          {
            severity: 'major',
            description:
              'Function `aVeryLongFunction` has 52 lines of code (exceeds 25 allowed). Consider refactoring.',
            line: 3,
          },
          {
            severity: 'minor',
            description: 'Arrow function has too many statements (52). Maximum allowed is 30.',
            line: 3,
          },
        ],
      },
    };

    it.each`
      line | severity
      ${1} | ${'minor'}
      ${2} | ${'no'}
      ${3} | ${'major'}
      ${4} | ${'no'}
    `('shows $severity icon for line $line', ({ line, severity }) => {
      createComponent({ line: { right: { new_line: line } } });

      if (severity === 'no') {
        expect(findIcon().exists()).toBe(false);
      } else {
        expect(findIcon().exists()).toBe(true);
        expect(findIcon().attributes()).toEqual({
          class: SEVERITY_CLASSES[severity],
          name: SEVERITY_ICONS[severity],
          size: '12',
        });
      }
    });
  });
});
