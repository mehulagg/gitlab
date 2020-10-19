import { shallowMount } from '@vue/test-utils';
import { GlEmptyState } from '@gitlab/ui';

import PipelineAuthoringApp from '~/pipeline_authoring/pipeline_authoring_app.vue';

describe('~/pipeline_authoring/pipeline_authoring_app.vue', () => {
  let wrapper;

  const createComponent = () => {
    wrapper = shallowMount(PipelineAuthoringApp);
  };

  beforeEach(() => {
    createComponent();
  });

  it('contains an empty state', () => {
    expect(wrapper.find(GlEmptyState).exists()).toBe(true);
  });
});
