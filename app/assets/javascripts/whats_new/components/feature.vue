<script>
import { GlBadge, GlIcon, GlLink } from '@gitlab/ui';

export default {
  components: {
    GlBadge,
    GlIcon,
    GlLink,
  },
  props: {
    feature: {
      type: Object,
      required: true,
      default: null,
    },
  },
};
</script>

<template>
  <div class="gl-pb-7 gl-pt-5 gl-px-5 gl-border-b-1 gl-border-b-solid gl-border-b-gray-100">
    <gl-link
      :href="feature.url"
      target="_blank"
      class="whats-new-item-title-link"
      data-track-event="click_whats_new_item"
      :data-track-label="feature.title"
      :data-track-property="feature.url"
    >
      <h5 class="gl-font-lg">{{ feature.title }}</h5>
    </gl-link>
    <div v-if="feature.packages" class="gl-mb-3">
      <gl-badge
        v-for="package_name in feature.packages"
        :key="package_name"
        size="sm"
        class="whats-new-item-badge gl-mr-2"
      >
        <gl-icon name="license" />{{ package_name }}
      </gl-badge>
    </div>
    <gl-link
      :href="feature.url"
      target="_blank"
      data-track-event="click_whats_new_item"
      :data-track-label="feature.title"
      :data-track-property="feature.url"
    >
      <img
        :alt="feature.title"
        :src="feature.image_url"
        class="img-thumbnail gl-px-8 gl-py-3 whats-new-item-image"
      />
    </gl-link>
    <div class="gl-pt-3" v-html="feature.body"></div>
    <gl-link
      :href="feature.url"
      target="_blank"
      data-track-event="click_whats_new_item"
      :data-track-label="feature.title"
      :data-track-property="feature.url"
      >{{ __('Learn more') }}</gl-link
    >
  </div>
</template>
