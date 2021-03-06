<script>
import { GlLoadingIcon, GlTooltipDirective } from '@gitlab/ui';
import { __ } from '~/locale';
import { referenceQueries } from '~/sidebar/constants';
import ClipboardButton from '~/vue_shared/components/clipboard_button.vue';

export default {
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  components: {
    ClipboardButton,
    GlLoadingIcon,
  },
  inject: ['fullPath', 'iid'],
  props: {
    issuableType: {
      required: true,
      type: String,
    },
  },
  data() {
    return {
      reference: '',
      title: __('Copy reference'),
      text: __('Reference'),
    };
  },
  apollo: {
    reference: {
      query() {
        return referenceQueries[this.issuableType].query;
      },
      variables() {
        return {
          fullPath: this.fullPath,
          iid: this.iid,
        };
      },
      update(data) {
        return data.workspace?.issuable?.reference || '';
      },
    },
  },
  computed: {
    isLoading() {
      return this.$apollo.queries.reference.loading;
    },
  },
  methods: {
    updateTooltip() {
      this.title = __('Copied!');
    },
  },
};
</script>

<template>
  <div class="project-reference sub-block">
    <clipboard-button
      :title="title"
      :text="reference"
      css-class="btn-clipboard btn-link sidebar-collapsed-icon dont-change-state"
      tooltip-placement="left"
      @click="updateTooltip()"
    />
    <div class="cross-project-reference hide-collapsed">
      <span>
        {{ text }}: {{ reference }}
        <gl-loading-icon v-if="isLoading" inline :label="text" />
      </span>
      <clipboard-button
        :title="title"
        :text="reference"
        css-class="btn-clipboard btn-link gl-line-height-24! gl-display-block"
        tooltip-placement="left"
        @click="updateTooltip()"
      />
    </div>
  </div>
</template>
