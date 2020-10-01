<script>
import Clipboard from 'clipboard';
import { GlDropdown, GlDropdownItem, GlIcon } from '@gitlab/ui';
import eventHub from '../event_hub';

export default {
  components: {
    GlDropdown,
    GlDropdownItem,
    GlIcon,
  },
  props: {
    newIssuePath: {
      type: String,
      required: true,
    },
    blobPath: {
      type: String,
      required: true,
    },
    blamePath: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      lineRange: [],
    };
  },
  computed: {
    showDropdown() {
      return this.lineRange.filter(l => l).length > 0;
    },
    lineRangeHash() {
      return `#L${this.lineRange.filter(l => l).join('-')}`;
    },
    fullPermalink() {
      return `${this.blobPath}${this.lineRangeHash}`;
    },
    issuePath() {
      return `${this.newIssuePath}?issue[description]=${this.fullPermalink}`;
    },
    fullBlamePath() {
      return `${this.blamePath}${this.lineRangeHash}`;
    },
  },
  mounted() {
    this.watchShowDropdown = this.$watch('showDropdown', val => {
      if (val) {
        this.clipboard = new Clipboard('#permalink-btn', {
          text: () => {
            return this.fullPermalink;
          },
        });
        this.watchShowDropdown();
      }
    });

    eventHub.$on('highlight:line', this.setLineRange);
  },
  beforeDestroy() {
    this.watchShowDropdown();

    if (this.clipboard) {
      this.clipboard.destroy();
    }

    eventHub.$off('highlight:line', this.setLineRange);
  },
  methods: {
    getPosition() {
      const lineEl = document.getElementById(`L${this.lineRange[0]}`);

      if (!lineEl) return {};

      return { top: `${lineEl.offsetTop - 3}px`, left: `${lineEl.offsetLeft - 20}px` };
    },
    setLineRange(range) {
      this.lineRange = range;
    },
  },
};
</script>

<template>
  <gl-dropdown
    v-if="showDropdown"
    :style="getPosition()"
    toggle-class="btn-icon btn-sm"
    class="position-absolute blob-line-dropdown"
  >
    <template #button-content>
      <gl-icon name="ellipsis_h" class="mr-0" />
      <span class="sr-only">{{ __('Options') }}</span>
    </template>
    <gl-dropdown-item id="permalink-btn">
      {{ __('Copy permalink') }}
    </gl-dropdown-item>
    <gl-dropdown-item :href="fullBlamePath">{{ __('View git blame') }}</gl-dropdown-item>
    <gl-dropdown-item :href="issuePath">{{ __('Create new issue') }}</gl-dropdown-item>
  </gl-dropdown>
</template>
