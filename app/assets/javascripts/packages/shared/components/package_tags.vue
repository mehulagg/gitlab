<script>
import { GlBadge, GlIcon, GlSprintf, GlTooltipDirective } from '@gitlab/ui';
import { GlBreakpointInstance } from '@gitlab/ui/dist/utils';
import { n__ } from '~/locale';

export default {
  name: 'PackageTags',
  components: {
    GlBadge,
    GlIcon,
    GlSprintf,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    tagDisplayLimit: {
      type: Number,
      required: false,
      default: 2,
    },
    tags: {
      type: Array,
      required: true,
      default: () => [],
    },
    hideLabel: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  data() {
    return {
      isDesktop: true,
    };
  },
  computed: {
    tagCount() {
      return this.tags.length;
    },
    tagsLimit() {
      return this.isDesktop ? this.tagDisplayLimit : Infinity;
    },
    tagsToRender() {
      return this.tags.slice(0, this.tagsLimit);
    },
    moreTagsDisplay() {
      return Math.max(0, this.tags.length - this.tagsLimit);
    },
    moreTagsTooltip() {
      if (this.moreTagsDisplay) {
        return this.tags
          .slice(this.tagsLimit)
          .map(x => x.name)
          .join(', ');
      }

      return '';
    },
    tagsDisplay() {
      return n__('%d tag', '%d tags', this.tagCount);
    },
  },
  mounted() {
    this.isDesktop = GlBreakpointInstance.isDesktop();
  },
  methods: {
    tagBadgeClass(index) {
      return {
        'gl-display-flex': true,
        'gl-mr-2': index !== this.tagsToRender.length - 1,
        'gl-ml-3': !this.hideLabel && index === 0,
        'gl-mt-2': !this.isDesktop,
      };
    },
  },
};
</script>

<template>
  <div class="gl-display-flex gl-align-items-center gl-flex-wrap">
    <div v-if="!hideLabel" data-testid="tagLabel" class="gl-display-flex gl-align-items-center">
      <gl-icon name="labels" class="gl-text-gray-500 gl-mr-3" />
      <span class="gl-font-weight-bold">{{ tagsDisplay }}</span>
    </div>

    <gl-badge
      v-for="(tag, index) in tagsToRender"
      :key="index"
      data-testid="tagBadge"
      :class="tagBadgeClass(index)"
      variant="info"
      size="sm"
      >{{ tag.name }}</gl-badge
    >

    <gl-badge
      v-if="moreTagsDisplay"
      v-gl-tooltip
      data-testid="moreBadge"
      variant="muted"
      :title="moreTagsTooltip"
      size="sm"
      class="gl-display-none gl-display-md-flex gl-ml-2"
      ><gl-sprintf :message="__('+%{tags} more')">
        <template #tags>
          {{ moreTagsDisplay }}
        </template>
      </gl-sprintf></gl-badge
    >

    <gl-badge
      v-if="moreTagsDisplay && hideLabel"
      data-testid="moreBadge"
      variant="muted"
      class="gl-display-md-none gl-ml-2"
      >{{ tagsDisplay }}</gl-badge
    >
  </div>
</template>
