import { flatten } from 'lodash';
import { s__ } from '~/locale';
import { shouldDisableShortcuts } from './shortcuts_toggle';

let parsedCustomizations;
try {
  parsedCustomizations = JSON.parse(window.gon.keyboard_shortcut_customizations || '{}');
} catch {
  parsedCustomizations = {};
}

/**
 * A map of command => keys of all keyboard shortcuts
 * that have been customized by the user.
 *
 * @example
 * { "editing.toggleMarkdownPreview": ["command+shift+o"] }
 *
 * @type { Object.<string, string[]> }
 */
export const customizations = parsedCustomizations;

// All available commands
export const TOGGLE_MARKDOWN_PREVIEW = 'editing.toggleMarkdownPreview';
export const TOGGLE_PERFORMANCE_BAR = 'globalShortcuts.togglePerformanceBar';
// ...etc...

/** All keybindings, grouped and ordered with descriptions */
export const keybindings = [
  {
    groupId: 'globalShortcuts',
    name: s__('Global Shortcuts'),
    keybindings: [
      {
        description: s__('Toggle the Performance Bar'),
        command: TOGGLE_PERFORMANCE_BAR,
        // eslint-disable-next-line @gitlab/require-i18n-strings
        defaultKeys: ['p b'],
      },
    ],
  },
  {
    groupId: 'editing',
    name: s__('Editing'),
    keybindings: [
      {
        description: s__('Toggle Markdown preview'),
        command: TOGGLE_MARKDOWN_PREVIEW,
        defaultKeys: ['command+shift+p'],
      },
    ],
  },
  // ...etc...
]

  // For each keybinding object, add a `customKeys` property
  // populated with the user's custom keybindings (if the
  // command has been customized). `customKeys` will be
  // `undefined` if the command hasn't been customized.
  .map(group => {
    return {
      ...group,
      keybindings: group.keybindings.map(binding => ({
        ...binding,
        customKeys: customizations[binding.command],
      })),
    };
  });

/**
 * A simple map of command => keys. All user customizations are included in this map.
 * This mapping is used to simplify `keysFor` below.
 *
 * @example
 * { "editing.toggleMarkdownPreview": ["command+shift+o"] }
 */
const commandToKeys = flatten(keybindings.map(group => group.keybindings)).reduce(
  (map, binding) => ({
    ...map,
    [binding.command]: binding.customKeys || binding.defaultKeys,
  }),
  {},
);

/**
 * Gets keyboard shortcuts associated with a command
 *
 * @param {string} command The command string. All command
 * strings are available as imports from this file.
 *
 * @returns {string[]} An array of keyboard shortcut strings bound to the command
 *
 * @example
 * import { keysFor, TOGGLE_MARKDOWN_PREVIEW } from '~/behaviors/shortcuts/keybindings'
 *
 * Mousetrap.bind(keysFor(TOGGLE_MARKDOWN_PREVIEW), handler);
 */
export const keysFor = command => {
  // TODO: Right now this uses our existing `shortcutsDisabled` flag,
  // which lives in `localStorage`. This value should instead be saved
  // in the database, along with the rest of these keyboard shortcut preferences.
  // Issue to track this: https://gitlab.com/gitlab-org/gitlab/-/issues/202494.
  if (shouldDisableShortcuts()) {
    return [];
  }

  return commandToKeys[command];
};
