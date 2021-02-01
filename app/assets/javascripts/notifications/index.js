import Vue from 'vue';
import { GlToast } from '@gitlab/ui';
import { parseBoolean } from '~/lib/utils/common_utils';
import NotificationsDropdown from './components/notifications_dropdown.vue';

Vue.use(GlToast);

export default () => {
  const container = document.querySelectorAll('.js-vue-notification-dropdown');

  if (!container.length) return false;

  container.forEach((el) => {
    const {
      containerClass,
      buttonSize,
      disabled,
      dropdownItems,
      notificationLevel,
      projectId,
      groupId,
      showLabel,
    } = el.dataset;

    console.log(
      'initNotificationsDropdown :: ',
      buttonSize,
      disabled,
      JSON.parse(dropdownItems),
      notificationLevel,
      projectId,
      groupId,
      showLabel,
      el,
    );

    return new Vue({
      el,
      provide: {
        containerClass,
        buttonSize,
        disabled: parseBoolean(disabled),
        dropdownItems: JSON.parse(dropdownItems),
        initialNotificationLevel: notificationLevel,
        projectId,
        groupId,
        showLabel: parseBoolean(showLabel),
      },
      render(h) {
        return h(NotificationsDropdown);
      },
    });
  });
};
