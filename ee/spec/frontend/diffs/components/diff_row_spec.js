import { shallowMount } from '@vue/test-utils';
import Vue from 'vue';
import Vuex from 'vuex';
import CodeQualityGutterIcon from 'ee/diffs/components/code_quality_gutter_icon.vue';
import DiffRow from '~/diffs/components/diff_row.vue';
import diffsModule from '~/diffs/store/modules';

Vue.use(Vuex);

describe('EE DiffRow', () => {
  let wrapper;

  const findIcon = () => wrapper.findComponent(CodeQualityGutterIcon);

  const defaultProps = {
    fileHash: 'abc',
    filePath: 'abc',
    line: {},
    index: 0,
  };

  const createComponent = ({ props, state, actions, isLoggedIn = true, provide }) => {
    const diffs = diffsModule();
    diffs.state = { ...diffs.state, ...state };
    diffs.actions = { ...diffs.actions, ...actions };

    const getters = { isLoggedIn: () => isLoggedIn };

    const store = new Vuex.Store({
      modules: { diffs },
      getters,
    });

    wrapper = shallowMount(DiffRow, { propsData: { ...defaultProps, ...props }, store, provide });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  describe('with feature flag enabled', () => {
    beforeEach(() => {
      createComponent({
        props: { line: { right: { codequality: [{ severity: 'critical' }] } } },
        provide: { glFeatures: { codequalityMrDiffAnnotations: true } },
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
        provide: { glFeatures: { codequalityMrDiffAnnotations: false } },
      });
    });

    it('does not code quality gutter icon', () => {
      expect(findIcon().exists()).toBe(false);
    });
  });
});
