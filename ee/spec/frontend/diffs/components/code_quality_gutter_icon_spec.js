import { GlIcon } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import Vue from 'vue';
import Vuex from 'vuex';
import CodeQualityGutterIcon from 'ee/diffs/components/code_quality_gutter_icon.vue';
import createDiffsStore from 'jest/diffs/create_diffs_store';
import CodequalityIssueBody from '~/reports/codequality_report/components/codequality_issue_body.vue';
import { SEVERITY_CLASSES, SEVERITY_ICONS } from '~/reports/codequality_report/constants';

Vue.use(Vuex);

describe('EE CodeQualityGutterIcon', () => {
  let store;
  let wrapper;
  let codequalityDiff;

  const findIcon = () => wrapper.findComponent(GlIcon);

  const defaultProps = {
    filePath: 'index.js',
    codequality: [
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
  };

  const createComponent = (props = {}, extendStore = () => {}) => {
    store = createDiffsStore();
    store.state.diffs.codequalityDiff = codequalityDiff;

    extendStore(store);

    wrapper = shallowMount(CodeQualityGutterIcon, {
      propsData: { ...defaultProps, ...props },
      store,
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  it.each`
    severity
    ${'info'}
    ${'minor'}
    ${'major'}
    ${'critical'}
    ${'blocker'}
    ${'unknown'}
  `('shows icon for $severity degradation', ({ severity }) => {
    createComponent({ codequality: [{ severity }] });

    expect(findIcon().exists()).toBe(true);
    expect(findIcon().attributes()).toMatchObject({
      class: `gl-hover-cursor-pointer codequality-severity-icon ${SEVERITY_CLASSES[severity]}`,
      name: SEVERITY_ICONS[severity],
      size: '12',
    });
  });

  describe('code quality modal', () => {
    beforeEach(() => {
      createComponent();
    });

    it('opens a code quality modal on click', () => {
      const modalId = 'codequality-index.js:3';
      const rootEmit = jest.spyOn(wrapper.vm.$root, '$emit');
      wrapper.findComponent(GlIcon).trigger('click');

      expect(rootEmit.mock.calls[0]).toContainEqual(modalId);
    });

    it('passes the issue data into the issue components correctly', () => {
      const issueProps = wrapper
        .findAllComponents(CodequalityIssueBody)
        .wrappers.map((w) => w.props());

      expect(issueProps).toEqual([
        {
          issue: {
            path: defaultProps.filePath,
            severity: defaultProps.codequality[0].severity,
            name: defaultProps.codequality[0].description,
            line: defaultProps.codequality[0].line,
          },
          status: 'neutral',
        },
        {
          issue: {
            path: defaultProps.filePath,
            severity: defaultProps.codequality[1].severity,
            name: defaultProps.codequality[1].description,
            line: defaultProps.codequality[1].line,
          },
          status: 'neutral',
        },
      ]);
    });
  });
});
