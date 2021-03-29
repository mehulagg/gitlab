<script>
import { GlButton, GlTooltipDirective, GlIcon } from '@gitlab/ui';
import axios from '~/lib/utils/axios_utils';
import { __ } from '~/locale';
import EmojiPicker from '../../components/picker.vue';

const DEFAULT_AWARDS = ['thumbsup', 'thumbsdown'];

export default {
  components: {
    GlButton,
    GlIcon,
    EmojiPicker,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    defaultAwards: {
      type: Array,
      required: true,
    },
    canAward: {
      type: Boolean,
      required: true,
    },
    awardUrl: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      awards: this.defaultAwards,
      isMenuOpen: false,
    };
  },
  methods: {
    async toggleAward(emoji) {
      try {
        await axios.post(this.awardUrl, { name: emoji });

        this.handleEmojiSuccess(emoji);
      } catch (e) {
        // TODO: Show error message
      }
    },
    handleEmojiSuccess(emoji) {
      const existingAward = this.awards.find((award) => award.emoji === emoji);

      if (existingAward) {
        if (existingAward.has_awarded) {
          existingAward.count -= 1;
        } else {
          existingAward.count += 1;
        }

        existingAward.has_awarded = !existingAward.has_awarded;

        if (existingAward.count === 0) {
          if (!DEFAULT_AWARDS.includes(emoji)) {
            this.awards = this.awards.filter((award) => award.emoji !== emoji);
          } else {
            existingAward.title = '';
          }
        }
      } else {
        this.awards.push({
          has_awarded: true,
          title: __('You'),
          count: 1,
          emoji,
        });
      }
    },
    setIsMenuOpen(menuOpen) {
      this.isMenuOpen = menuOpen;
    },
  },
};
</script>

<template>
  <div class="awards vue-awards">
    <gl-button
      v-for="(award, index) in awards"
      :key="index"
      v-gl-tooltip
      :title="award.title"
      :class="{ 'is-active': award.has_awarded }"
      :disabled="!canAward"
      class="award-control"
      @click="toggleAward(award.emoji)"
    >
      <gl-emoji :data-name="award.emoji" class="gl-font-size-h2!" />
      <span class="award-control-text">
        {{ award.count }}
      </span>
    </gl-button>
    <emoji-picker
      v-if="canAward"
      :toggle-class="['award-control gl-pr-4! gl-relative!', { 'is-active': isMenuOpen }]"
      @click="toggleAward"
      @shown="setIsMenuOpen(true)"
      @hidden="setIsMenuOpen(false)"
    >
      <template #button-content>
        <span class="award-control-icon award-control-icon-neutral">
          <gl-icon name="slight-smile" />
        </span>
        <span class="award-control-icon award-control-icon-positive">
          <gl-icon name="smiley" />
        </span>
        <span class="award-control-icon award-control-icon-super-positive">
          <gl-icon name="smile" />
        </span>
      </template>
    </emoji-picker>
  </div>
</template>
