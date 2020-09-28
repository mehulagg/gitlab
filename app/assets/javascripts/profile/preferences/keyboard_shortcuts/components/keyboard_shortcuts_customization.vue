<script>
import { mapState, mapGetters, mapActions } from 'vuex';
import { GlLink, GlFormGroup, GlFormInput, GlToggle } from '@gitlab/ui';
import {
  shouldDisableShortcuts,
  enableShortcuts,
  disableShortcuts,
} from '~/behaviors/shortcuts/shortcuts_toggle';
import KeyboardShortcutGroup from './keyboard_shortcut_group.vue';

export default {
  name: 'KeyboardShortcutsCustomization',
  components: { GlLink, GlFormGroup, GlFormInput, GlToggle, KeyboardShortcutGroup },
  data() {
    return {
      shortcutsEnabled: !shouldDisableShortcuts(),
    };
  },
  computed: {
    ...mapState(['learnMorePath', 'formFieldName', 'keybindings']),
    ...mapGetters(['customizations']),
  },
  methods: {
    ...mapActions(['updateKeybinding']),
    onGlobalShortcutToggleChanged(enabled) {
      // TODO: Right now this is just toggling the flag in `localStorage`
      // that we use currently; this configuration should instead be saved in the
      // database and managed similarly to keyboard shortcut customizations.
      // Issue to track this: https://gitlab.com/gitlab-org/gitlab/-/issues/202494
      if (enabled) {
        enableShortcuts();
      } else {
        disableShortcuts();
      }
    },
  },
};
</script>
<template>
  <div class="keyboard-shortcut-customizations col-12">
    <div class="row mb-4">
      <div class="col-sm-12">
        <hr />
      </div>

      <div id="keyboard-shortcuts" class="col-lg-4 profile-settings">
        <h4 class="gl-mt-0">{{ s__('Preferences|Keyboard Shortcuts') }}</h4>
        <p>
          {{ s__('Preferences|Enable or disable keyboard shortcuts.') }}
          <gl-link :href="learnMorePath" target="_blank">{{ __('Learn more.') }}</gl-link>
        </p>
      </div>

      <div class="col-lg-8">
        <gl-form-group>
          <gl-toggle
            v-model="shortcutsEnabled"
            :label="s__('Preferences|Shortcuts enabled')"
            label-position="left"
            @change="onGlobalShortcutToggleChanged($event)"
          />
        </gl-form-group>

        <hr />

        <keyboard-shortcut-group
          :group="group"
          v-for="group in keybindings"
          :key="group.grouopId"
        />

        <!-- <gl-form-group
            v-for="binding in group.keybindings"
            :key="binding.command"
            :label="binding.description"
          >
            <gl-form-input
              :value="getBindingKeys(binding)"
              @change="updateKeybinding({ command: binding.command, newKeys: JSON.parse($event) })"
            />
          </gl-form-group> -->

        <p class="gl-font-style-italic">Some info for debugging:</p>

        <label><code>keybindings</code> JSON:</label>
        <pre>{{ JSON.stringify(keybindings, null, 2) }}</pre>

        <br />

        <input type="hidden" :name="formFieldName" :value="JSON.stringify(customizations)" />
        <label><code>customizations</code> JSON:</label>
        <pre>{{ customizations }}</pre>
      </div>
    </div>
  </div>
</template>
