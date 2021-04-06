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
    const clientTarget = new EventTarget();
    const workerTarget = new EventTarget();

    this.addEventListener = (...args) => clientTarget.addEventListener(...args);
    this.postMessage = (message) =>
      workerTarget.dispatchEvent(new MessageEvent('message', { data: message }));
    this.removeEventListener = (...args) => clientTarget.removeEventListener(...args);
    this.terminate = () => {
      this.removeEventListener('message');
    };

    const scope = {
      addEventListener: (...args) => workerTarget.addEventListener(...args),
      postMessage: (message) =>
        clientTarget.dispatchEvent(new MessageEvent('message', { data: message })),
      removeEventListener: (...args) => workerTarget.removeEventListener(...args),
    };

    // eslint-disable-next-line no-new-func
    Function('self', 'require', code)(scope, createRelativeRequire(filename));
  }
}
