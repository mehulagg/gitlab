import Vue from 'vue';
import tooltip from '~/vue_shared/directives/tooltip';
import { s__, __ } from '~/locale';

export default boardsStore => {
  const configEl = document.querySelector('.js-board-config');

  if (configEl) {
    gl.boardConfigToggle = new Vue({
      el: configEl,
      directives: {
        tooltip,
      },
      data() {
        return {
          canAdminList: this.$options.el.hasAttribute('data-can-admin-list'),
          hasScope: this.$options.el.hasAttribute('data-has-scope'),
          state: boardsStore.state,
        };
      },
      computed: {
        buttonText() {
          return this.canAdminList ? s__('Boards|Edit board') : s__('Boards|View scope');
        },
        tooltipTitle() {
          return this.hasScope ? __("This board's scope is reduced") : '';
        },
      },
      methods: {
        showPage: page => boardsStore.showPage(page),
      },
      template: `
        <div class="gl-ml-3">
          <button
            v-tooltip
            :title="tooltipTitle"
            class="btn btn-inverted"
            :class="{ 'dot-highlight': hasScope }"
            type="button"
            data-qa-selector="boards_config_button"
            @click.prevent="showPage('edit')"
          >
            {{ buttonText }}
          </button>
        </div>
      `,
    });
  }
};
