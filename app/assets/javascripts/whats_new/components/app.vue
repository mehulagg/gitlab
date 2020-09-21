<script>
import { mapState, mapActions } from 'vuex';
import { GlDrawer, GlBadge, GlIcon, GlLink } from '@gitlab/ui';
import axios from '~/lib/utils/axios_utils';
import SkeletonLoader from './skeleton_loader.vue';

export default {
  components: {
    GlDrawer,
    GlBadge,
    GlIcon,
    GlLink,
    SkeletonLoader,
  },
  props: {
    storageKey: {
      type: String,
      required: true,
      default: null,
    },
  },
  data() {
    return {
      features: null,
    };
  },
  computed: {
    ...mapState(['open']),
  },
  mounted() {
    this.openDrawer(this.storageKey);
    this.fetchItems();
  },
  methods: {
    ...mapActions(['openDrawer', 'closeDrawer']),
    fetchItems() {
      return axios.get('/-/whats_new').then(({ data }) => {
        this.features = data;
      });
    },
  },
};
</script>

<template>
  <div>
    <gl-drawer class="whats-new-drawer" :open="open" @close="closeDrawer">
      <template #header>
        <h4 class="page-title my-2">{{ __("What's new at GitLab") }}</h4>
      </template>
      <div class="pb-6">
        <template v-if="features">
          <div v-for="feature in features" :key="feature.title" class="mb-6">
            <gl-link :href="feature.url" target="_blank">
              <h5 class="gl-font-base">{{ feature.title }}</h5>
            </gl-link>
            <div class="mb-2">
              <template v-for="package_name in feature.packages">
                <gl-badge :key="package_name" size="sm" class="whats-new-item-badge mr-1">
                  <gl-icon name="license" />{{ package_name }}
                </gl-badge>
              </template>
            </div>
            <gl-link :href="feature.url" target="_blank">
              <img
                :alt="feature.title"
                :src="feature.image_url"
                class="img-thumbnail px-6 py-2 whats-new-item-image"
              />
            </gl-link>
            <p class="pt-2">{{ feature.body }}</p>
            <gl-link :href="feature.url" target="_blank">{{ __('Learn more') }}</gl-link>
          </div>
        </template>
        <div v-else class="mt-3">
          <skeleton-loader />
          <skeleton-loader />
        </div>
      </div>
    </gl-drawer>
    <div v-if="open" class="whats-new-modal-backdrop modal-backdrop"></div>
  </div>
</template>
