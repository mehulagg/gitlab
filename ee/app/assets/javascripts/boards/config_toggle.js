import Vue from 'vue';
import ConfigToggle from './components/config_toggle.vue';

export default (boardsStore) => {
  const configEl = document.querySelector('.js-board-config');

  if (configEl) {
    gl.boardConfigToggle = new Vue({
      el: configEl,
      render(h) {
        return h(ConfigToggle, {
          props: {
            boardsStore,
            canAdminList: configEl.hasAttribute('data-can-admin-list'),
            hasScope: configEl.hasAttribute('data-has-scope'),
          },
        });
      },
    });
  }
};
