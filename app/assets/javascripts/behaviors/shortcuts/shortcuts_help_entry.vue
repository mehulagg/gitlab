<script>
import { __, s__ } from '~/locale';

const keyMap = {
  up: '↑',
  down: '↓',
  left: '←',
  right: '→',
  mod: window.gl.client.isMac ? '⌘' : s__('KeyboardKey|ctrl'),
  shift: s__('KeyboardKey|shift'),
  enter: s__('KeyboardKey|enter'),
  esc: s__('KeyboardKey|esc'),
  command: '⌘',
};

export default {
  functional: true,
  props: {
    keybinding: {
      type: Object,
      required: true,
    },
  },
  render(createElement, context) {
    // TODO: Add support for customized keys. I wonder if the help should have a hint if the keys are customized
    const shortcuts = context.props.keybinding.defaultKeys.flatMap((shortcut, i) => {
      const keys = shortcut.split(/([ +])/);
      const mapped = [];

      if (i !== 0) {
        mapped.push(` ${__('or')} `);
      }

      keys.forEach((key) => {
        if (key === '+') {
          mapped.push(' + ');
        } else if (key === ' ') {
          mapped.push(' ⇒ ');
        } else {
          const value = keyMap[key] ? keyMap[key] : key;
          mapped.push(createElement('kbd', {}, [value]));
        }
      });

      return mapped;
    });

    return createElement('div', {}, shortcuts);
  },
};
</script>
