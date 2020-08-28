import $ from 'jquery';
import Vue from 'vue';
import Translate from '~/vue_shared/translate';
import { highCountTrim } from '~/lib/utils/text_utility';
import SetStatusModalTrigger from './set_status_modal/set_status_modal_trigger.vue';
import SetStatusModalWrapper from './set_status_modal/set_status_modal_wrapper.vue';
import { parseBoolean } from '~/lib/utils/common_utils';
import Tracking from '~/tracking';
import { globalOn, TODO_TOGGLE } from '~/helpers/global_event_hub';

/**
 * Updates todo counter when todos are toggled.
 * When count is 0, we hide the badge.
 */
export default function initTodoToggle() {
  globalOn(TODO_TOGGLE, count => {
    const updatedCount = count || 0;
    const $todoPendingCount = document.querySelector('.todos-count');

    $todoPendingCount.textContent = highCountTrim(updatedCount);
    $todoPendingCount.classList.toggle('hidden', updatedCount === 0);
  });
}

function initStatusTriggers() {
  const setStatusModalTriggerEl = document.querySelector('.js-set-status-modal-trigger');
  const setStatusModalWrapperEl = document.querySelector('.js-set-status-modal-wrapper');

  if (setStatusModalTriggerEl || setStatusModalWrapperEl) {
    Vue.use(Translate);

    // eslint-disable-next-line no-new
    new Vue({
      el: setStatusModalTriggerEl,
      data() {
        const { hasStatus } = this.$options.el.dataset;

        return {
          hasStatus: parseBoolean(hasStatus),
        };
      },
      render(createElement) {
        return createElement(SetStatusModalTrigger, {
          props: {
            hasStatus: this.hasStatus,
          },
        });
      },
    });

    // eslint-disable-next-line no-new
    new Vue({
      el: setStatusModalWrapperEl,
      data() {
        const { currentEmoji, currentMessage } = this.$options.el.dataset;

        return {
          currentEmoji,
          currentMessage,
        };
      },
      render(createElement) {
        const { currentEmoji, currentMessage } = this;

        return createElement(SetStatusModalWrapper, {
          props: {
            currentEmoji,
            currentMessage,
          },
        });
      },
    });
  }
}

function trackShowUserDropdownLink(trackEvent, elToTrack, el) {
  const { trackLabel, trackProperty } = elToTrack.dataset;

  $(el).on('shown.bs.dropdown', () => {
    Tracking.event(document.body.dataset.page, trackEvent, {
      label: trackLabel,
      property: trackProperty,
    });
  });
}
export function initNavUserDropdownTracking() {
  const el = document.querySelector('.js-nav-user-dropdown');
  const buyEl = document.querySelector('.js-buy-pipeline-minutes-link');
  const upgradeEl = document.querySelector('.js-upgrade-plan-link');

  if (el && buyEl) {
    trackShowUserDropdownLink('show_buy_ci_minutes', buyEl, el);
  }

  if (el && upgradeEl) {
    trackShowUserDropdownLink('show_upgrade_link', upgradeEl, el);
  }
}

document.addEventListener('DOMContentLoaded', () => {
  requestIdleCallback(initStatusTriggers);
  initNavUserDropdownTracking();
});
