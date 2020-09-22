<script>
import { mapState } from 'vuex';
import { n__ } from '~/locale';
import TitleArea from '~/vue_shared/components/registry/title_area.vue';
import MetadataItem from '~/vue_shared/components/registry/metadata_item.vue';
import { LIST_INTRO_TEXT, LIST_TITLE_TEXT } from '../constants';

export default {
  name: 'PackageTitle',
  components: {
    TitleArea,
    MetadataItem,
  },
  computed: {
    ...mapState(['pagination', 'config']),
    packageAmountText() {
      return n__(`%d Package`, `%d Packages`, this.pagination?.total);
    },
    infoMessages() {
      return [{ text: LIST_INTRO_TEXT, link: this.config.packageHelpUrl }];
    },
  },
  i18n: {
    LIST_TITLE_TEXT,
  },
};
</script>

<template>
  <title-area :title="$options.i18n.LIST_TITLE_TEXT" :info-messages="infoMessages">
    <template #metadata_amount>
      <metadata-item icon="package" :text="packageAmountText" />
    </template>
  </title-area>
</template>
