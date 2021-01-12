import { editor as monacoEditor, languages as monacoLanguages, Uri } from 'monaco-editor';
import { DEFAULT_THEME, themes } from '~/ide/lib/themes';
import languages from '~/ide/lib/languages';
import { defaultEditorOptions } from '~/ide/lib/editor_options';
import { registerLanguages } from '~/ide/utils';
import { joinPaths } from '~/lib/utils/url_utility';
import { clearDomElement } from './utils';
import { EDITOR_LITE_INSTANCE_ERROR_NO_EL, URI_PREFIX, EDITOR_TYPE_DIFF } from './constants';
import { uuids } from '~/diffs/utils/uuids';

export default class EditorLite {
  constructor(options = {}) {
    this.instances = [];
    this.options = {
      extraEditorClassName: 'gl-editor-lite',
      ...defaultEditorOptions,
      ...options,
    };

    EditorLite.setupMonacoTheme();

    registerLanguages(...languages);
  }

  static setupMonacoTheme() {
    const themeName = window.gon?.user_color_scheme || DEFAULT_THEME;
    const theme = themes.find((t) => t.name === themeName);
    if (theme) monacoEditor.defineTheme(themeName, theme.data);
    monacoEditor.setTheme(theme ? themeName : DEFAULT_THEME);
  }

  static updateModelLanguage(path, instance) {
    if (!instance) return;
    const model = instance.getModel();
    const ext = `.${path.split('.').pop()}`;
    const language = monacoLanguages
      .getLanguages()
      .find((lang) => lang.extensions.indexOf(ext) !== -1);
    const id = language ? language.id : 'plaintext';
    monacoEditor.setModelLanguage(model, id);
  }

  static pushToImportsArray(arr, toImport) {
    arr.push(import(toImport));
  }

  static loadExtensions(extensions) {
    if (!extensions) {
      return Promise.resolve();
    }
    const promises = [];
    const extensionsArray = typeof extensions === 'string' ? extensions.split(',') : extensions;

    extensionsArray.forEach((ext) => {
      const prefix = ext.includes('/') ? '' : 'editor/';
      const trimmedExt = ext.replace(/^\//, '').trim();
      EditorLite.pushToImportsArray(promises, `~/${prefix}${trimmedExt}`);
    });

    return Promise.all(promises);
  }

  static mixIntoInstance(source, inst) {
    if (!inst) {
      return;
    }
    const isClassInstance = source.constructor.prototype !== Object.prototype;
    const sanitizedSource = isClassInstance ? source.constructor.prototype : source;
    Object.getOwnPropertyNames(sanitizedSource).forEach((prop) => {
      if (prop !== 'constructor') {
        Object.assign(inst, { [prop]: source[prop] });
      }
    });
  }

  static prepareInstance(el) {
    if (!el) {
      throw new Error(EDITOR_LITE_INSTANCE_ERROR_NO_EL);
    }

    clearDomElement(el);

    monacoEditor.onDidCreateEditor(() => {
      delete el.dataset.editorLoading;
    });
  }

  static manageDefaultExtensions(instance, el, extensions) {
    EditorLite.loadExtensions(extensions, instance)
      .then((modules) => {
        if (modules) {
          modules.forEach((module) => {
            instance.use(module.default);
          });
        }
      })
      .then(() => {
        el.dispatchEvent(new Event('editor-ready'));
      })
      .catch((e) => {
        throw e;
      });
  }

  static createEditorModel({
    blobPath = '',
    blobContent = '',
    originalBlobContent = null,
    blobGlobalId = uuids()[0],
    instance = null,
  } = {}) {
    if (instance) {
      const uriFilePath = joinPaths(URI_PREFIX, blobGlobalId, blobPath);
      const existingModel = monacoEditor.getModel(uriFilePath);
      const model =
        existingModel || monacoEditor.createModel(blobContent, undefined, Uri.file(uriFilePath));
      if (originalBlobContent === null) {
        instance.setModel(model);
      } else {
        instance.setModel({
          original: monacoEditor.createModel(originalBlobContent, undefined, Uri.file(uriFilePath)),
          modified: model,
        });
      }
    }
  }

  /**
   * Creates a monaco instance with the given options.
   *
   * @param {Object} options Options used to initialize monaco.
   * @param {Element} options.el The element which will be used to create the monacoEditor.
   * @param {string} options.blobPath The path used as the URI of the model. Monaco uses the extension of this path to determine the language.
   * @param {string} options.blobContent The content to initialize the monacoEditor.
   * @param {string} options.blobGlobalId This is used to help globally identify monaco instances that are created with the same blobPath.
   */
  createInstance({
    el = undefined,
    blobPath = '',
    blobContent = '',
    originalBlobContent = '',
    blobGlobalId = uuids()[0],
    extensions = [],
    diff = false,
    ...instanceOptions
  } = {}) {
    EditorLite.prepareInstance(el);

    let instance;

    if (!diff) {
      instance = monacoEditor.create(el, {
        ...this.options,
        ...instanceOptions,
      });
      if (instanceOptions.model !== null) {
        EditorLite.createEditorModel({ blobGlobalId, blobPath, blobContent, instance });
      }
    } else {
      instance = monacoEditor.createDiffEditor(el, {
        ...this.options,
        ...instanceOptions,
      });
      if (instanceOptions.model !== null) {
        EditorLite.createEditorModel({
          blobGlobalId,
          originalBlobContent,
          blobPath,
          blobContent,
          instance,
        });
      }
    }

    Object.assign(instance, {
      updateModelLanguage: (path) => EditorLite.updateModelLanguage(path, instance),
      use: (args) => this.use(args, instance),
    });

    instance.onDidDispose(() => {
      const index = this.instances.findIndex((inst) => inst === instance);
      this.instances.splice(index, 1);
      const instanceModel = instance.getModel();
      if (instanceModel) {
        if (instance.getEditorType() === EDITOR_TYPE_DIFF) {
          const { original, modified } = instanceModel;
          if (original) {
            original.dispose();
          }
          if (modified) {
            modified.dispose();
          }
        } else {
          instanceModel.dispose();
        }
      }
    });
    EditorLite.manageDefaultExtensions(instance, el, extensions);

    this.instances.push(instance);
    return instance;
  }

  createDiffInstance(args) {
    this.createInstance({
      ...args,
      diff: true,
    });
  }

  dispose() {
    this.instances.forEach((instance) => instance.dispose());
  }

  use(exts = [], instance = null) {
    const extensions = Array.isArray(exts) ? exts : [exts];
    const initExtensions = (inst) => {
      extensions.forEach((extension) => {
        EditorLite.mixIntoInstance(extension, inst);
      });
    };
    if (instance) {
      initExtensions(instance);
      return instance;
    }
    this.instances.forEach((inst) => {
      initExtensions(inst);
    });
    return this;
  }
}
