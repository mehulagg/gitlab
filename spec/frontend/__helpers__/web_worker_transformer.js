/* eslint-disable import/no-commonjs */
const babelJestTransformer = require('babel-jest');

module.exports = {
  process: (contentArg, filename, ...args) => {
    const { code: content } = babelJestTransformer.process(contentArg, filename, ...args);

    return `const { FakeWebWorker } = require("helpers/web_worker_fake");
    module.exports = class JestTransformedWorker extends FakeWebWorker {
      constructor() {
        super(${JSON.stringify(filename)}, ${JSON.stringify(content)});
      }
    };`;
  },
};
