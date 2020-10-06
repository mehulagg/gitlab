import $ from 'jquery';
import Vue from 'vue';
import { mapActions } from 'vuex';
import { GlButton, GlTooltipDirective } from '@gitlab/ui';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import { __ } from '~/locale';
import eventHub from '~/sidebar/event_hub';

export default Vue.extend({
  components: {
    GlButton,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  mixins: [glFeatureFlagsMixin()],
  props: {
    list: {
      type: Object,
      default: () => ({}),
      required: false,
    },
  },
  methods: {
    ...mapActions(['deleteList']),
    deleteBoard() {
      $(this.$el).tooltip('hide');
      eventHub.$emit('sidebar.closeAll');

      // eslint-disable-next-line no-alert
      if (window.confirm(__('Are you sure you want to delete this list?'))) {
        if (this.glFeatures.graphqlBoardLists) {
          this.deleteList(this.list.id);
        } else {
          this.list.destroy();
        }
      }
    },
  },
});
