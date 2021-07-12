<script>
import { __, n__ } from '~/locale';
import DrawerAvatarsList from '../shared/drawer_avatars_list.vue';
import DrawerSectionHeader from '../shared/drawer_section_header.vue';

export default {
  components: {
    DrawerAvatarsList,
    DrawerSectionHeader,
  },
  props: {
    committers: {
      type: Array,
      required: false,
      default: () => [],
    },
  },
  computed: {
    committersHeaderText() {
      return n__('%d commit author', '%d commit authors', this.committers.length);
    },
  },
  i18n: {
    header: __('Change made by'),
    emptyHeader: __('No committers'),
  },
};
</script>
<template>
  <div>
    <drawer-section-header>{{ $options.i18n.header }}</drawer-section-header>
    <drawer-avatars-list
      :header="committersHeaderText"
      :empty-header="$options.i18n.emptyHeader"
      :avatars="committers"
    />
  </div>
</template>
