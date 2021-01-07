import Disposable from '../common/disposable';

export default class DirtyDiffController {
  constructor(modelManager, decorationsController) {
    this.disposable = new Disposable();
    this.models = new Map();
    this.editorSimpleWorker = null;
    this.modelManager = modelManager;
    this.decorationsController = decorationsController;
  }

  attachModel(model) {
    if (this.models.has(model.url)) return;

    model.onDispose(() => {
      this.decorationsController.removeDecorations(model);
      this.models.delete(model.url);
    });

    this.models.set(model.url, model);
  }

  reDecorate(model) {
    if (this.decorationsController.hasDecorations(model)) {
      this.decorationsController.decorate(model);
    }
  }

  dispose() {
    this.disposable.dispose();
    this.models.clear();
  }
}
