import path from 'path';

const isRelative = (pathArg) => pathArg.startsWith('.');

const transformRequirePath = (base, pathArg) => {
  if (!isRelative(pathArg)) {
    return pathArg;
  }

  return path.resolve(base, pathArg);
};

const createRelativeRequire = (filename) => {
  const rel = path.relative(__dirname, path.dirname(filename));
  const base = path.resolve(__dirname, rel);

  // eslint-disable-next-line import/no-dynamic-require, global-require
  return (pathArg) => require(transformRequirePath(base, pathArg));
};

export class FakeWebWorker {
  constructor(filename, code) {
    let isAlive = true;

    const clientTarget = new EventTarget();
    const workerTarget = new EventTarget();

    this.addEventListener = (...args) => clientTarget.addEventListener(...args);
    this.removeEventListener = (...args) => clientTarget.removeEventListener(...args);
    this.postMessage = (message) => {
      if (!isAlive) {
        return;
      }

      workerTarget.dispatchEvent(new MessageEvent('message', { data: message }));
    };
    this.terminate = () => {
      isAlive = false;
    };

    const workerScope = {
      addEventListener: (...args) => workerTarget.addEventListener(...args),
      removeEventListener: (...args) => workerTarget.removeEventListener(...args),
      postMessage: (message) => {
        if (!isAlive) {
          return;
        }

        clientTarget.dispatchEvent(new MessageEvent('message', { data: message }));
      },
    };

    // eslint-disable-next-line no-new-func
    Function('self', 'require', code)(workerScope, createRelativeRequire(filename));
  }
}
