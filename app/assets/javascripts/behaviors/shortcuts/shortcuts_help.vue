<script>
import { GlModal } from '@gitlab/ui';
import { keybindingGroups } from './keybindings';
import ShortcutsHelpEntry from './shortcuts_help_entry.vue';
import ShortcutsToggle from './shortcuts_toggle.vue';

export default {
  components: {
    GlModal,
    ShortcutsToggle,
    ShortcutsHelpEntry,
  },
  keybindingGroups,
};
</script>
<template>
  <gl-modal
    modal-id="keyboard-shortcut-modal"
    size="lg"
    data-testid="modal-shortcuts"
    :visible="true"
    :hide-footer="true"
    @hidden="$emit('hidden')"
  >
    <template #modal-title>
      <shortcuts-toggle />
    </template>
    <div class="gl-display-flex gl-flex-direction-column gl-flex-wrap shortcut-mappings">
      <section v-for="group in $options.keybindingGroups" :key="group.id">
        <h5>{{ group.name }}</h5>
        <div
          v-for="keybinding in group.keybindings"
          :key="keybinding.id"
          class="gl-display-flex gl-align-items-center"
        >
          <div class="gl-w-half gl-flex-shrink-0">{{ keybinding.description }}</div>
          <shortcuts-help-entry class="gl-w-half" :keybinding="keybinding" />
        </div>
      </section>
    </div>
  </gl-modal>
</template>
