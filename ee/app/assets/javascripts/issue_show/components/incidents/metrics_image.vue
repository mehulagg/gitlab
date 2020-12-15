<script>
import { GlButton, GlCard, GlIcon, GlLink } from '@gitlab/ui';
import { mapActions } from 'vuex';

export default {
  components: {
    GlButton,
    GlCard,
    GlIcon,
    GlLink,
  },
  props: {
    id: {
      type: Number,
      required: true,
    },
    filePath: {
      type: String,
      required: true,
    },
    filename: {
      type: String,
      required: true,
    },
    url: {
      type: String,
      required: false,
      default: null,
    },
  },
  data() {
    return {
      isCollapsed: false,
      isDeleting: false,
    };
  },
  computed: {
    arrowIconName() {
      return this.isCollapsed ? 'chevron-right' : 'chevron-down';
    },
    bodyClass() {
      return [
        'gl-border-1',
        'gl-border-t-solid',
        'gl-border-gray-100',
        { 'gl-display-none': !this.showBody },
      ];
    },
    showBody() {
      return !this.loading && !this.isCollapsed;
    },
  },
  methods: {
    ...mapActions(['deleteImage']),
    toggleCollapsed() {
      this.isCollapsed = !this.isCollapsed;
    },
    async handleClick() {
      try {
        this.isDeleting = true;
        await this.deleteImage(this.id);
      } finally {
        this.isDeleting = false;
      }
    },
  },
};
</script>

<template>
  <gl-card
    class="collapsible-card border gl-p-0 gl-mb-5"
    header-class="d-flex align-items-center border-bottom-0 gl-py-3"
    :body-class="bodyClass"
  >
    <template #header>
      <div class="gl-w-full gl-display-flex gl-flex-direction-row gl-justify-content-space-between">
        <div class="gl-display-flex gl-flex-direction-row gl-align-items-center gl-w-full">
          <gl-button
            class="collapsible-card-btn gl-display-flex gl-text-decoration-none gl-reset-color! gl-hover-text-blue-800! gl-shadow-none!"
            :aria-label="filename"
            variant="link"
            category="tertiary"
            data-testid="collapse-button"
            @click="toggleCollapsed"
          >
            <gl-icon class="gl-mr-2" :name="arrowIconName" />
          </gl-button>
          <gl-link v-if="url" :href="url">
            {{ filename }}
          </gl-link>
          <span v-else>{{ filename }}</span>
          <gl-button class="gl-ml-auto" icon="remove" :loading="isDeleting" @click="handleClick" />
        </div>
      </div>
    </template>
    <div
      v-show="showBody"
      class="gl-display-flex gl-flex-direction-column"
      data-testid="metric-image-body"
    >
      <img class="gl-max-w-full gl-align-self-center" :src="filePath" />
    </div>
  </gl-card>
</template>
