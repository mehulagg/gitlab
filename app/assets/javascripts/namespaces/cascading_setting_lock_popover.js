import Vue from 'vue';
import CascadingSettingLockPopover from './components/cascading_setting_lock_popover.vue';

export const initCascadingSettingLockPopover = () => {
  const el = document.querySelector('.js-cascading-setting-lock-popovers');

  if (!el) return false;

  return new Vue({
    el,
    render(createElement) {
      return createElement(CascadingSettingLockPopover);
    },
  });
};
