import { debounce } from 'lodash';
import { editor as monacoEditor, KeyCode, KeyMod, Range } from 'monaco-editor';
import Disposable from '~/ide/lib/common/disposable';
import DecorationsController from '~/ide/lib/decorations/controller';
import { editorOptions } from '~/ide/lib/editor_options';
import DirtyDiffController from '~/ide/lib/diff/controller';
import keymap from '~/ide/lib/keymap.json';
import { EditorLiteExtension } from '~/editor/extensions/editor_lite_extension_base';
import ModelManager from '~/ide/lib/common/model_manager';
import { EDITOR_TYPE_DIFF } from '~/editor/constants';

const isDiffEditorType = (instance) => {
  return instance.getEditorType() === EDITOR_TYPE_DIFF;
};

export class EditorWebIdeExtension extends EditorLiteExtension {
  constructor({ instance, ...options } = {}) {
    super({
      instance,
      ...options,
      currentModel: null,
      dirtyDiffController: null,
      disposable: new Disposable(),
      modelManager: new ModelManager(),
      decorationsController: new DecorationsController(instance),
      debouncedUpdate: debounce(() => {
        instance.updateDimensions();
      }, 200),
    });

    instance.disposable.add(
      (this.dirtyDiffController = new DirtyDiffController(
        instance.modelManager,
        instance.decorationsController,
      )),
    );

    window.addEventListener('resize', instance.debouncedUpdate, false);

    instance.onDidDispose(() => {
      window.removeEventListener('resize', instance.debouncedUpdate);

      // catch any potential errors with disposing the error
      // this is mainly for tests caused by elements not existing
      try {
        instance.disposable.dispose();

        // this.instance = null;
      } catch (e) {
        // this.instance = null;

        if (process.env.NODE_ENV !== 'test') {
          // eslint-disable-next-line no-console
          console.error(e);
        }
      }
    });
  }

  bootstrapInstance() {
    // if (!this.instance) {
    //   clearDomElement(domElement);

    // this.disposable.add(
    //   (this.dirtyDiffController = new DirtyDiffController(
    //     this.modelManager,
    //     this.decorationsController,
    //   )),
    // );

    this.addCommands();

    // window.addEventListener('resize', this.debouncedUpdate, false);
    // }
  }

  bootstrapDiffInstance() {
    // if (!this.instance) {
    //   clearDomElement(domElement);
    debugger;
    this.updateOptions({
      renderSideBySide: EditorWebIdeExtension.renderSideBySide(this.getDomNode()),
    });

    this.addCommands();

    // window.addEventListener('resize', this.debouncedUpdate, false);
    // }
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
    if (this.dirtyDiffController) this.dirtyDiffController.attachModel(model);

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

    if (this.dirtyDiffController) this.dirtyDiffController.reDecorate(model);
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
    // if (this.instance) {
    this.setModel(null);
    // }
  }

  updateDimensions() {
    // if (this.instance) {
    this.layout();
    this.updateDiffView();
    // }
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

    debugger;
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
