/* global monaco */
import monacoLoader from 'ee/ide/monaco_loader';
import editor from 'ee/ide/lib/editor';
import { file } from '../helpers';

describe('Multi-file editor library', () => {
  let instance;
  let el;
  let holder;

  beforeEach(done => {
    el = document.createElement('div');
    holder = document.createElement('div');
    el.appendChild(holder);

    document.body.appendChild(el);

    monacoLoader(['vs/editor/editor.main'], () => {
      instance = editor.create(monaco);

      done();
    });
  });

  afterEach(() => {
    instance.dispose();

    el.remove();
  });

  it('creates instance of editor', () => {
    expect(editor.editorInstance).not.toBeNull();
  });

  it('creates instance returns cached instance', () => {
    expect(editor.create(monaco)).toEqual(instance);
  });

  describe('createInstance', () => {
    it('creates editor instance', () => {
      spyOn(instance.monaco.editor, 'create').and.callThrough();

      instance.createInstance(holder);

      expect(instance.monaco.editor.create).toHaveBeenCalled();
    });

    it('creates dirty diff controller', () => {
      instance.createInstance(holder);

      expect(instance.dirtyDiffController).not.toBeNull();
    });

    it('creates model manager', () => {
      instance.createInstance(holder);

      expect(instance.modelManager).not.toBeNull();
    });
  });

  describe('createDiffInstance', () => {
    it('creates editor instance', () => {
      spyOn(instance.monaco.editor, 'createDiffEditor').and.callThrough();

      instance.createDiffInstance(holder);

      expect(instance.monaco.editor.createDiffEditor).toHaveBeenCalledWith(
        holder,
        {
          model: null,
          contextmenu: true,
          minimap: {
            enabled: false,
          },
          readOnly: true,
          scrollBeyondLastLine: false,
        },
      );
    });
  });

  describe('createModel', () => {
    it('calls model manager addModel', () => {
      spyOn(instance.modelManager, 'addModel');

      instance.createModel('FILE');

      expect(instance.modelManager.addModel).toHaveBeenCalledWith('FILE');
    });
  });

  describe('attachModel', () => {
    let model;

    beforeEach(() => {
      instance.createInstance(document.createElement('div'));

      model = instance.createModel(file());
    });

    it('sets the current model on the instance', () => {
      instance.attachModel(model);

      expect(instance.currentModel).toBe(model);
    });

    it('attaches the model to the current instance', () => {
      spyOn(instance.instance, 'setModel');

      instance.attachModel(model);

      expect(instance.instance.setModel).toHaveBeenCalledWith(model.getModel());
    });

    it('sets original & modified when diff editor', () => {
      spyOn(instance.instance, 'getEditorType').and.returnValue(
        'vs.editor.IDiffEditor',
      );
      spyOn(instance.instance, 'setModel');

      instance.attachModel(model);

      expect(instance.instance.setModel).toHaveBeenCalledWith({
        original: model.getOriginalModel(),
        modified: model.getModel(),
      });
    });

    it('attaches the model to the dirty diff controller', () => {
      spyOn(instance.dirtyDiffController, 'attachModel');

      instance.attachModel(model);

      expect(instance.dirtyDiffController.attachModel).toHaveBeenCalledWith(
        model,
      );
    });

    it('re-decorates with the dirty diff controller', () => {
      spyOn(instance.dirtyDiffController, 'reDecorate');

      instance.attachModel(model);

      expect(instance.dirtyDiffController.reDecorate).toHaveBeenCalledWith(
        model,
      );
    });
  });

  describe('clearEditor', () => {
    it('resets the editor model', () => {
      instance.createInstance(document.createElement('div'));

      spyOn(instance.instance, 'setModel');

      instance.clearEditor();

      expect(instance.instance.setModel).toHaveBeenCalledWith(null);
    });
  });

  describe('dispose', () => {
    it('calls disposble dispose method', () => {
      spyOn(instance.disposable, 'dispose').and.callThrough();

      instance.dispose();

      expect(instance.disposable.dispose).toHaveBeenCalled();
    });

    it('resets instance', () => {
      instance.createInstance(document.createElement('div'));

      expect(instance.instance).not.toBeNull();

      instance.dispose();

      expect(instance.instance).toBeNull();
    });

    it('does not dispose modelManager', () => {
      spyOn(instance.modelManager, 'dispose');

      instance.dispose();

      expect(instance.modelManager.dispose).not.toHaveBeenCalled();
    });

    it('does not dispose decorationsController', () => {
      spyOn(instance.decorationsController, 'dispose');

      instance.dispose();

      expect(instance.decorationsController.dispose).not.toHaveBeenCalled();
    });
  });
});
