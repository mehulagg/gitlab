import eventHub from '~/ide/eventhub';
import ModelManager from '~/ide/lib/common/model_manager';
import { file } from '../../helpers';

describe('Multi-file editor library model manager', () => {
  let instance;

  beforeEach(() => {
    instance = new ModelManager();
  });

  afterEach(() => {
    instance.dispose();
  });

  describe('addModel', () => {
    it('caches model', () => {
      instance.addModel(file());

      expect(instance.models.size).toBe(1);
    });

    it('caches model by file path', () => {
      const f = file('path-name');
      instance.addModel(f);

      expect(instance.models.keys().next().value).toBe(f.key);
    });

    it('adds model into disposable', () => {
      spyOn(instance.disposable, 'add').and.callThrough();

      instance.addModel(file());

      expect(instance.disposable.add).toHaveBeenCalled();
    });

    it('returns cached model', () => {
      spyOn(instance.models, 'get').and.callThrough();

      instance.addModel(file());
      instance.addModel(file());

      expect(instance.models.get).toHaveBeenCalled();
    });

    it('adds eventHub listener', () => {
      const f = file();
      spyOn(eventHub, '$on').and.callThrough();

      instance.addModel(f);

      expect(eventHub.$on).toHaveBeenCalledWith(
        `editor.update.model.dispose.${f.key}`,
        jasmine.anything(),
      );
    });
  });

  describe('hasCachedModel', () => {
    it('returns false when no models exist', () => {
      expect(instance.hasCachedModel('path')).toBeFalsy();
    });

    it('returns true when model exists', () => {
      const f = file('path-name');

      instance.addModel(f);

      expect(instance.hasCachedModel(f.key)).toBeTruthy();
    });
  });

  describe('getModel', () => {
    it('returns cached model', () => {
      instance.addModel(file('path-name'));

      expect(instance.getModel('path-name')).not.toBeNull();
    });
  });

  describe('removeCachedModel', () => {
    let f;

    beforeEach(() => {
      f = file();

      instance.addModel(f);
    });

    it('clears cached model', () => {
      instance.removeCachedModel(f);

      expect(instance.models.size).toBe(0);
    });

    it('removes eventHub listener', () => {
      spyOn(eventHub, '$off').and.callThrough();

      instance.removeCachedModel(f);

      expect(eventHub.$off).toHaveBeenCalledWith(
        `editor.update.model.dispose.${f.key}`,
        jasmine.anything(),
      );
    });
  });

  describe('dispose', () => {
    it('clears cached models', () => {
      instance.addModel(file());

      instance.dispose();

      expect(instance.models.size).toBe(0);
    });

    it('calls disposable dispose', () => {
      spyOn(instance.disposable, 'dispose').and.callThrough();

      instance.dispose();

      expect(instance.disposable.dispose).toHaveBeenCalled();
    });
  });
});
