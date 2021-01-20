import Vue from 'vue';
import NotificationsDropdown from './components/notifications_dropdown.vue';

export default () => {
  const el = document.querySelector('.js-vue-notification-dropdown');

  if (!el) return false;

  const { buttonSize, disabled, dropdownItems, notificationLevel, projectId, groupId } = el.dataset;

  return new Vue({
    el,
    provide: {
      buttonSize,
      disabled: Boolean(disabled),
      dropdownItems: JSON.parse(dropdownItems),
      initialNotificationLevel: notificationLevel,
      projectId,
      groupId,
    },
    render(h) {
      return h(NotificationsDropdown);
    },
  });
};
