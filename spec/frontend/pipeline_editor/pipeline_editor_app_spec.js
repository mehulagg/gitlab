import { shallowMount } from '@vue/test-utils';
import { GlEmptyState } from '@gitlab/ui';

import PipelineEditorApp from '~/pipeline_editor/pipeline_editor_app.vue';

describe('~/pipeline_editor/pipeline_editor_app.vue', () => {
  let wrapper;

  const createComponent = (mountFn = shallowMount) => {
    wrapper = mountFn(PipelineEditorApp);
  };

  beforeEach(() => {
    createComponent();
  });

  it('contains an empty state', () => {
    expect(wrapper.find(GlEmptyState).exists()).toBe(true);
  });

  it('contains a title and description', () => {
    expect(wrapper.find(GlEmptyState).props('title')).toBeTruthy();
    expect(wrapper.find(GlEmptyState).props('description')).toBeTruthy();
  });
});
