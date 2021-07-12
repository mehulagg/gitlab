<script>
import { __, n__ } from '~/locale';
import { DRAWER_AVATAR_SIZE } from '../../constants';
import DrawerAvatarsList from '../shared/drawer_avatars_list.vue';
import DrawerSectionHeader from '../shared/drawer_section_header.vue';

export default {
  components: {
    DrawerAvatarsList,
    DrawerSectionHeader,
  },
  props: {
    approvers: {
      type: Array,
      required: false,
      default: () => [],
    },
    commenters: {
      type: Array,
      required: false,
      default: () => [],
    },
  },
  computed: {
    commentersHeaderText() {
      return n__('%d commenter', '%d commenters', this.commenters.length);
    },
    approversHeaderText() {
      return n__('%d approver', '%d approvers', this.approvers.length);
    },
    hasCommenters() {
      return this.commenters.length > 0;
    },
    hasApprovers() {
      return this.approvers.length > 0;
    },
  },
  i18n: {
    header: __('Peer review by'),
    commentersEmptyHeader: __('No commenters'),
    approversEmptyHeader: __('No approvers'),
  },
  DRAWER_AVATAR_SIZE,
};
</script>
<template>
  <div>
    <drawer-section-header>{{ $options.i18n.header }}</drawer-section-header>
    <drawer-avatars-list
      :header="commentersHeaderText"
      :empty-header="$options.i18n.commentersEmptyHeader"
      :avatars="commenters"
      data-testid="commenters-avatar-list"
    />
    <drawer-avatars-list
      class="gl-mt-4"
      :header="approversHeaderText"
      :empty-header="$options.i18n.approversEmptyHeader"
      :avatars="approvers"
      data-testid="approvers-avatar-list"
    />
  </div>
</template>
