<script>
import { GlLabel, GlIcon, GlLink, GlPopover } from '@gitlab/ui';
import { __, n__, s__ } from '~/locale';

export default {
  i18n: {
    blockedIssue: __('Blocked issue'),
    blockedByIssue: `Blocked by %d issue`,
    blockedByIssues: `Blocked by %d issues`,
    viewAllIssue: s__('Boards|View all blocking issues'),
    moreBlockedIssue: `+ %d more issue`,
    moreBlockedIssues: `+ %d more issues`,
  },
  components: {
    GlLabel,
    GlIcon,
    GlPopover,
    GlLink,
  },
  inject: ['groupId', 'rootPath'],
  props: {
    item: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      issuableLink: 'asdfasdf',
      hiddenBlockedIssues: 2,
      issuables: [
        {
          title: 'issue1',
          iid: '1',
          description: 'adsfadsf',
          webUrl: '',
        },
        {
          title: 'issue2',
          iid: '2',
          description: 'djsfa;iosghioasdhgioadsfjioadsfjioadsfj adsifjioadsj fadsiofj',
          webUrl: '',
        },
      ],
    };
  },
  computed: {
    itemReferencePath() {
      const { referencePath } = this.item;
      return referencePath.split(this.itemPrefix)[0];
    },
    blockedLabel() {
      if (this.item.blockedByCount) {
        return n__(
          this.$options.i18n.blockedByIssue,
          this.$options.i18n.blockedByIssues,
          this.item.blockedByCount,
        );
      }
      return this.$options.i18n.blockedIssue;
    },

    glIconId() {
      return `blocked-icon-for-${this.item.iid}`;
    },
    containerId() {
      return `blocked-popover-container-${this.item.iid}`;
    },
    hasMoreIssues() {
      // TODO
      return true;
    },
    moreIssuesText() {
      return n__(
        this.$options.i18n.moreBlockedIssue,
        this.$options.i18n.moreBlockedIssue,
        this.hiddenBlockedIssues,
      );
    },
  },
};
</script>
<template>
  <div :id="containerId" class="gl-display-inline">
    <gl-icon
      name="issue-block"
      :id="glIconId"
      class="issue-blocked-icon gl-mr-2"
      data-testid="issue-blocked-icon"
    />
    <gl-popover :target="glIconId" :container="containerId" placement="top" triggers="hover focus">
      <template #title>{{ blockedLabel }}</template>
      <ul class="gl-list-style-none gl-p-0">
        <li v-for="issuable in issuables" :key="issuable.iid">
          <gl-link :href="issuableLink" class="gl-text-blue-500! gl-font-sm">issue 1</gl-link>
          <p class="gl-mb-3">{{ issuable.description }}</p>
        </li>
      </ul>
      <div v-if="hasMoreIssues" class="gl-mt-4">
        <p class="gl-mb-3">{{ moreIssuesText }}</p>
        <gl-link :href="issuableLink" class="gl-text-blue-500! gl-font-sm">{{
          $options.i18n.viewAllIssue
        }}</gl-link>
      </div>
    </gl-popover>
  </div>
</template>
