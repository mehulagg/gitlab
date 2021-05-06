import { mapValues, isFunction } from 'lodash';
import Tracking from '~/tracking';
import { CONTENT_EDITOR_TRACKING_LABEL, KEYBOARD_SHORTCUT_TRACKING_ACTION } from '../constants';

const trackKeyboardShortcut = (contentType, commandFn, shortcut) => () => {
  Tracking.event(undefined, KEYBOARD_SHORTCUT_TRACKING_ACTION, {
    label: CONTENT_EDITOR_TRACKING_LABEL,
    property: `${contentType}.${shortcut}`,
  });
  return commandFn();
};

const trackInputRulesAndShortcuts = (tiptapExtension) => {
  if (!isFunction(tiptapExtension.config.addKeyboardShortcuts)) {
    return tiptapExtension;
  }

  const result = tiptapExtension.extend({
    /**
     * Note: we shouldn’t pass the parent extension config
     * to the children because it should be automatically
     * inherited.
     *
     * However we found an issue where the editor becomes
     * frozen if the paragraph extension is extended
     * without passing the parent config explicitely
     *
     * We reported the issue in the tiptap repository
     * https://github.com/ueberdosis/tiptap/issues/1288
     */
    ...tiptapExtension.config,
    addKeyboardShortcuts() {
      const shortcuts = this.parent();
      const { name } = this;
      const decorated = mapValues(shortcuts, (commandFn, shortcut) =>
        trackKeyboardShortcut(name, commandFn, shortcut),
      );

      return decorated;
    },
  });

  return result;
};

export default trackInputRulesAndShortcuts;
