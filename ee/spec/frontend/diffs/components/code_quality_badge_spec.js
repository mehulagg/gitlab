import { GlBadge } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import CodeQualityBadge from 'ee/diffs/components/code_quality_badge.vue';
import * as commonUtils from '~/lib/utils/common_utils';

describe('EE CodeQualityBadge', () => {
  let wrapper;

  beforeEach(() => {
    wrapper = shallowMount(CodeQualityBadge, {});
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('navigates to the code quality MR widget on click', () => {
    window.mrTabs = { eventHub: { $once: jest.fn() }, tabShown: jest.fn() };
    commonUtils.historyPushState = jest.fn();

    wrapper.find(GlBadge).trigger('click');

    expect(window.mrTabs.eventHub.$once).toHaveBeenCalledWith(
      'MergeRequestTabChange',
      expect.any(Function),
    );
    expect(window.mrTabs.tabShown).toHaveBeenCalledWith('show');
    expect(commonUtils.historyPushState).toHaveBeenCalledWith(window.location.href);
  });
});
