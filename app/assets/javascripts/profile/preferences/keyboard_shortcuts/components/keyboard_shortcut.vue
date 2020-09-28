<script>
import { s__ } from '~/locale';

export default {
  name: 'KeyboardShortcut',
  props: {
    keys: {
      type: Array,
      required: true,
    },
  },
  computed: {
    isMac() {
      // Accessing properties using ?. to allow tests to use
      // this component without setting up window.gl.client.
      // In production, window.gl.client should always be present.
      return Boolean(window.gl?.client?.isMac);
    },
    modifierKey() {
      return this.isMac ? '⌘' : s__('KeyboardKey|ctrl');
    },

    /**
     * Given a this.keys array like this:
     *
     * ```
     * ['meta+shift+o', 'p b']
     * ```
     *
     * ... an array like this is returned:
     *
     * ```
     * [
     *   ['⌘ shift o'],
     *   ['p', 'b']
     * ]
     * ```
     */
    keySegments() {
      console.log('keys:', this.keys);
      return this.keys.map(shortcut =>
        shortcut.split(/\s+/).map(segment => {
          let humanFriendlySegment = segment
            .replaceAll('meta', this.modifierKey)
            .replaceAll('+', ' ');

          return humanFriendlySegment;
        }),
      );
    },
  },
};
</script>

<template>
  <div class="gl-display-flex gl-align-items-center">
    <template v-for="(shortcut, index) in keySegments">
      <kbd v-for="segment in shortcut" class="gl-mr-2">{{ segment }}</kbd>
      <span v-if="index !== keySegments.length - 1" class="gl-mr-2">/</span>
    </template>
  </div>
</template>
