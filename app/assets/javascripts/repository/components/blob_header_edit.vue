<script>
import { GlButton } from '@gitlab/ui';
import { __ } from '~/locale';
import WebIdeLink from '~/vue_shared/components/web_ide_link.vue';

export default {
  i18n: {
    edit: __('Edit'),
    webIde: __('Web IDE'),
  },
  components: {
    GlButton,
    WebIdeLink,
  },
  props: {
    editPath: {
      type: String,
      required: true,
    },
    webIdePath: {
      type: String,
      required: true,
    },
  },
  computed: {
    isFeatureEnabled() {
      return Boolean(gon.features?.consolidatedEditButton);
    },
  },
};
</script>

<template>
  <web-ide-link
    v-if="isFeatureEnabled"
    class="gl-mr-3"
    :editUrl="editPath"
    :webIdeUrl="webIdePath"
    :isBlob="true"
  />
  <div v-else>
    <gl-button class="gl-mr-2" category="primary" variant="confirm" :href="editPath">
      {{ $options.i18n.edit }}
    </gl-button>

    <gl-button class="gl-mr-3" category="primary" variant="confirm" :href="webIdePath">
      {{ $options.i18n.webIde }}
    </gl-button>
  </div>
</template>
