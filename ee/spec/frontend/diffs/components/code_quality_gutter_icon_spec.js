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
      propsData: { ...props },
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
    expect(findIcon().attributes()).toEqual({
      class: SEVERITY_CLASSES[severity],
      name: SEVERITY_ICONS[severity],
      size: '12',
    });
  });
});
