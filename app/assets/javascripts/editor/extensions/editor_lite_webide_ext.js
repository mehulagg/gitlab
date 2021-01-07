import { debounce } from 'lodash';
import { editor as monacoEditor, KeyCode, KeyMod, Range } from 'monaco-editor';
import Disposable from '~/ide/lib/common/disposable';
import { editorOptions } from '~/ide/lib/editor_options';
import keymap from '~/ide/lib/keymap.json';
import { EditorLiteExtension } from '~/editor/extensions/editor_lite_extension_base';
import { EDITOR_TYPE_DIFF } from '~/editor/constants';

const isDiffEditorType = (instance) => {
  return instance.getEditorType() === EDITOR_TYPE_DIFF;
};

export class EditorWebIdeExtension extends EditorLiteExtension {
  constructor({ instance, modelManager, ...options } = {}) {
    super({
      instance,
      ...options,
      currentModel: null,
      modelManager,
      disposable: new Disposable(),
      debouncedUpdate: debounce(() => {
        instance.updateDimensions();
      }, 200),
    });

    window.addEventListener('resize', instance.debouncedUpdate, false);

    instance.onDidDispose(() => {
      window.removeEventListener('resize', instance.debouncedUpdate);

      // catch any potential errors with disposing the error
      // this is mainly for tests caused by elements not existing
      try {
        instance.disposable.dispose();
      } catch (e) {
        if (process.env.NODE_ENV !== 'test') {
          // eslint-disable-next-line no-console
          console.error(e);
        }
      }
    });
  }

  bootstrapInstance() {
    this.addCommands();
  }

  bootstrapDiffInstance() {
    this.updateOptions({
      renderSideBySide: EditorWebIdeExtension.renderSideBySide(this.getDomNode()),
    });

    this.bootstrapInstance();
  }

  createModel(file, head = null) {
    return this.modelManager.addModel(file, head);
  }

  attachModel(model) {
    if (isDiffEditorType(this)) {
      this.setModel({
        original: model.getOriginalModel(),
        modified: model.getModel(),
      });

      return;
    }

    this.setModel(model.getModel());

    this.currentModel = model;

    this.updateOptions(
      editorOptions.reduce((acc, obj) => {
        Object.keys(obj).forEach((key) => {
          Object.assign(acc, {
            [key]: obj[key](model),
          });
        });
        return acc;
      }, {}),
    );
  }

  attachMergeRequestModel(model) {
    this.setModel({
      original: model.getBaseModel(),
      modified: model.getModel(),
    });

    monacoEditor.createDiffNavigator(this, {
      alwaysRevealFirst: true,
    });
  }

  clearEditor() {
    this.setModel(null);
  }

  updateDimensions() {
    this.layout();
    this.updateDiffView();
  }

  setPos({ lineNumber, column }) {
    this.revealPositionInCenter({
      lineNumber,
      column,
    });
    this.setPosition({
      lineNumber,
      column,
    });
  }

  onPositionChange(cb) {
    if (!this.onDidChangeCursorPosition) return;

    this.disposable.add(this.onDidChangeCursorPosition((e) => cb(this, e)));
  }

  updateDiffView() {
    if (!isDiffEditorType(this)) return;

    this.updateOptions({
      renderSideBySide: EditorWebIdeExtension.renderSideBySide(this.getDomNode()),
    });
  }

  replaceSelectedText(text) {
    let selection = this.getSelection();
    const range = new Range(
      selection.startLineNumber,
      selection.startColumn,
      selection.endLineNumber,
      selection.endColumn,
    );

    this.executeEdits('', [{ range, text }]);

    selection = this.getSelection();
    this.setPosition({ lineNumber: selection.endLineNumber, column: selection.endColumn });
  }

  static renderSideBySide(domElement) {
    return domElement.offsetWidth >= 700;
  }

  addCommands() {
    const { store } = this;
    const getKeyCode = (key) => {
      const monacoKeyMod = key.indexOf('KEY_') === 0;

      return monacoKeyMod ? KeyCode[key] : KeyMod[key];
    };

    keymap.forEach((command) => {
      const keybindings = command.bindings.map((binding) => {
        const keys = binding.split('+');

        // eslint-disable-next-line no-bitwise
        return keys.length > 1 ? getKeyCode(keys[0]) | getKeyCode(keys[1]) : getKeyCode(keys[0]);
      });

      this.addAction({
        id: command.id,
        label: command.label,
        keybindings,
        run() {
          store.dispatch(command.action.name, command.action.params);
          return null;
        },
      });
    });
  }
}
