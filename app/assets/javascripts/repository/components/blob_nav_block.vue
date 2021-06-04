<script>
import { GlButton } from '@gitlab/ui';
import { __ } from '~/locale';

export default {
  i18n: {
    find: __('Find file'),
    blame: __('Blame'),
    history: __('History'),
    permalink: __('Permalink'),
  },
  components: {
    GlButton,
  },
  props: {
    findFilePath: {
      type: String,
      required: true,
    },
    blamePath: {
      type: String,
      required: true,
    },
    commitsPath: {
      type: String,
      required: true,
    },
    permalinkPath: {
      type: String,
      required: true,
    },
    readableText: {
      type: Boolean,
      required: false,
      default: true,
    },
  },
};
</script>

<template>
  <div class="nav-block">
    <div class="tree-ref-container">
      <div class="tree-ref-holder">
        <!-- TODO: Add ref dropdown -->
      </div>
      <ul class="breadcrumb repo-breadcrumb">
        <li class="breadcrumb-item">Project</li>
        <li class="breadcrumb-item">Path</li>
      </ul>
    </div>
    <div class="tree-controls gl-children-ml-sm-3">
      <gl-button :href="findFilePath">
        {{ $options.i18n.find }}
      </gl-button>

      <gl-button :href="blamePath">
        {{ $options.i18n.blame }}
      </gl-button>

      <gl-button :href="commitsPath">
        {{ $options.i18n.history }}
      </gl-button>

      <gl-button :href="permalinkPath">
        {{ $options.i18n.permalink }}
      </gl-button>
    </div>
  </div>
</template>
