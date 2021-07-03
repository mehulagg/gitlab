import { shallowMount } from '@vue/test-utils';
import Vue from 'vue';
import Vuex from 'vuex';
import DiffRow from '~/diffs/components/diff_row.vue';
import diffsModule from '~/diffs/store/modules';

Vue.use(Vuex);

describe('EE DiffRow', () => {
  let wrapper;

  const findIcon = () => wrapper.find('[data-testid="codeQualityIcon"]');

  const defaultProps = {
    fileHash: 'abc',
    filePath: 'abc',
    line: {},
    index: 0,
    isHighlighted: false,
    fileLineCoverage: () => ({}),
  };

  const createComponent = ({
    props,
    state,
    actions,
    isLoggedIn = true,
    codequalityMrDiffAnnotations,
  }) => {
    const diffs = diffsModule();
    diffs.state = { ...diffs.state, ...state };
    diffs.actions = { ...diffs.actions, ...actions };

    const getters = { isLoggedIn: () => isLoggedIn };

    const store = new Vuex.Store({
      modules: { diffs },
      getters,
    });

    window.gon = { features: { codequalityMrDiffAnnotations } };

    wrapper = shallowMount(DiffRow, {
      propsData: { ...defaultProps, ...props },
      store,
      listeners: {
        enterdragging: () => {},
        stopdragging: () => {},
        showCommentForm: () => {},
        setHighlightedRow: () => {},
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;

    window.gon = {};

    Object.values(DiffRow).forEach(({ cache }) => {
      if (cache) {
        cache.clear();
      }
    });
  });

  describe('with feature flag enabled', () => {
    beforeEach(() => {
      createComponent({
        props: { line: { right: { codequality: [{ severity: 'critical' }] } } },
        codequalityMrDiffAnnotations: true,
      });
    });

    it('shows code quality gutter icon', () => {
      expect(findIcon().exists()).toBe(true);
    });
  });

  describe('without feature flag enabled', () => {
    beforeEach(() => {
      createComponent({
        props: { line: { right: { codequality: [{ severity: 'critical' }] } } },
        codequalityMrDiffAnnotations: false,
      });
    });

    it('does not code quality gutter icon', () => {
      expect(findIcon().exists()).toBe(false);
    });
  });
});
