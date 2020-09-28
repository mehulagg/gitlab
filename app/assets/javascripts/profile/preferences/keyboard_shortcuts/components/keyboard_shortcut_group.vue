<script>
import { GlTable } from '@gitlab/ui';
import { s__ } from '~/locale';
import KeyboardShortcut from './keyboard_shortcut.vue';

export default {
  name: 'KeyboardShortcutGroup',
  components: { GlTable, KeyboardShortcut },
  props: {
    group: {
      type: Object,
      required: true,
    },
  },
  fields: [
    {
      key: 'command',
      label: s__('KeyboardShortcuts|Command'),
      customStyle: { width: '45%' },
    },
    {
      key: 'shortcut',
      label: s__('KeyboardShortcuts|Shortcut'),
      customStyle: { width: '45%' },
    },
    {
      key: 'actions',
    },
  ],
};
</script>

<template>
  <div>
    <h5 class="h4">{{ group.name }}</h5>
    <gl-table
      :fields="$options.fields"
      :items="group.keybindings"
      stacked="lg"
      table-class="text-secondary"
    >
      <template #table-colgroup="scope">
        <col v-for="field in scope.fields" :key="field.key" :style="field.customStyle" />
      </template>
      <template #cell(command)="{ item: binding }">
        <span>{{ binding.description }}</span>
      </template>
      <template #cell(shortcut)="{ item: binding }">
        <keyboard-shortcut :keys="binding.customKeys || binding.defaultKeys" />
      </template>
    </gl-table>
  </div>
</template>
