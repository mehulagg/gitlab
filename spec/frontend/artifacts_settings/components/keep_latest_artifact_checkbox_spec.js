import { GlFormCheckbox, GlLink } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import KeepLatestArtifactCheckbox from '~/artifacts_settings/keep_latest_artifact_checkbox.vue';

describe('Keep latest artifact checkbox', () => {
  let wrapper;

  const findCheckbox = () => wrapper.find(GlFormCheckbox);
  const findHelpLink = () => wrapper.find(GlLink);

  const createComponent = () => {
    wrapper = shallowMount(KeepLatestArtifactCheckbox);
  };

  beforeEach(() => {
    createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  it('displays the checkbox and the help link', () => {
    expect(findCheckbox().exists()).toBe(true);
    expect(findHelpLink().exists()).toBe(true);
  });
});
