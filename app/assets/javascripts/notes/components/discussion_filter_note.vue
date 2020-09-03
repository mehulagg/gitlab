<script>
import { GlButton, GlIcon, GlSprintf } from '@gitlab/ui';

import notesEventHub from '../event_hub';

export default {
  components: {
    GlButton,
    GlIcon,
    GlSprintf,
  },
  methods: {
    selectFilter(value) {
      notesEventHub.$emit('dropdownSelect', value);
    },
  },
};
</script>

<template>
  <li class="timeline-entry note note-wrapper discussion-filter-note js-discussion-filter-note">
    <div class="timeline-icon d-none d-lg-flex">
      <gl-icon name="comment" />
    </div>
    <div class="timeline-content">
      <div ref="timelineContent">
        <gl-sprintf
          :message="
            __(
              'You\'re only seeing %{boldStart}other activity%{boldEnd} in the feed. To add a comment, switch to one of the following options.'
            )
          "
        >
          <template #bold="{ content }">
            <b>{{ content }}</b>
          </template>
        </gl-sprintf>
      </div>
      <div class="discussion-filter-actions mt-2">
        <gl-button ref="showAllActivity" variant="default" @click="selectFilter(0)">
          {{ __('Show all activity') }}
        </gl-button>
        <gl-button ref="showComments" variant="default" @click="selectFilter(1)">
          {{ __('Show comments only') }}
        </gl-button>
      </div>
    </div>
  </li>
</template>
