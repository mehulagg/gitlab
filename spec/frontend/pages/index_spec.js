import { readdirSync, statSync } from 'fs';
import { join } from 'path';

function findIndexFiles(rootDir, directory = '') {
  const entries = readdirSync(join(rootDir, directory)).map(name => {
    const path = join(directory, name);
    const stats = statSync(join(rootDir, path));

    if (stats.isDirectory()) {
      return findIndexFiles(rootDir, path);
    } else if (stats.isFile() && name === 'index.js') {
      return [path];
    }

    return [];
  });

  return entries.reduce((a, b) => a.concat(b), []);
}

const rootDir = join(__dirname, '../../..', 'app/assets/javascripts/pages/');
const pageBundles = findIndexFiles(rootDir);

describe('Page bundle smoke tests', () => {
  describe.each(pageBundles)('%s', path => {
    jest.isolateModules(() => {
      it('does not break', () => {
        // eslint-disable-next-line global-require, import/no-dynamic-require
        expect(() => require(join(rootDir, path))).not.toThrow();
      });
    });
  });
});
