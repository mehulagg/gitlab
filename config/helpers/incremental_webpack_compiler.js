const fs = require('fs');
const path = require('path');

const log = (msg, ...rest) => console.log(`IncrementalWebpackCompiler: ${msg}`, ...rest);

// Just an arbitrary number that is long enough for people to _see_ and read the message
const TIMEOUT = 5000;

module.exports = class IncrementalWebpackCompiler {
  constructor(enabled, cacheFile) {
    this.enabled = enabled;
    log(`Status – ${enabled ? 'enabled' : 'disabled'}`);
    if (this.enabled) {
      this.history = {};
      this.compiledEntryPoints = new Set([
        // Login page
        'pages.sessions.new',
        // Explore page
        'pages.root',
      ]);
      this.cacheFile = cacheFile;
      this.loadFromCacheFile();
    }
  }

  filterEntryPoints(entrypoints) {
    if (!this.enabled) {
      return entrypoints;
    }

    return Object.fromEntries(
      Object.entries(entrypoints).map(([key, val]) => {
        if (this.compiledEntryPoints.has(key)) {
          return [key, val];
        }
        return [key, ['./webpack_non_compiled_placeholder.js']];
      }),
    );
  }

  logStatus(totalCount) {
    if (this.enabled) {
      const current = this.compiledEntryPoints.size;
      log(`Currently compiling route entrypoints: ${current} of ${totalCount}`);
    }
  }

  addToHistory(chunk) {
    if (!this.history[chunk]) {
      this.history[chunk] = { lastVisit: null, count: 0 };
    }
    this.history[chunk].lastVisit = Date.now();
    this.history[chunk].count += 1;

    try {
      fs.writeFileSync(this.cacheFile, JSON.stringify(this.history), 'utf8');
    } catch (e) {
      log('Warning – Could not write to history', e.message);
    }
  }

  setupMiddleware(app, server) {
    if (this.enabled) {
      app.use((req, res, next) => {
        const fileName = path.basename(req.url);

        /**
         * We are only interested in files that have a name like `pages.foo.bar.chunk.js`
         * because those are the ones corresponding to our entry points.
         *
         * This filters out hot update files that are for example named "pages.foo.bar.[hash].hot-update.js"
         */
        if (fileName.startsWith('pages.') && fileName.endsWith('.chunk.js')) {
          const chunk = fileName.replace(/\.chunk\.js$/, '');

          this.addToHistory(chunk);

          if (!this.compiledEntryPoints.has(chunk)) {
            log(`First time we are seeing ${chunk}. Adding to compilation.`);

            this.compiledEntryPoints.add(chunk);

            setTimeout(() => {
              server.middleware.invalidate(() => {
                if (server.sockets) {
                  server.sockWrite(server.sockets, 'content-changed');
                }
              });
            }, TIMEOUT);
          }
        }

        next();
      });
    }
  }

  loadFromCacheFile() {
    if (this.enabled) {
      try {
        this.history = JSON.parse(fs.readFileSync(this.cacheFile, 'utf8'));
        const chunks = Object.keys(this.history);
        log(`Successfully loaded history containing ${chunks.length} routes`);
        // TODO: Let's ask a few folks to give us their history file after a week or two of usage
        // Then we can make smarter decisions on what to throw out rather than rendering everything
        this.compiledEntryPoints = new Set([...this.compiledEntryPoints, ...chunks]);
      } catch (e) {
        log(`No history found...`);
      }
    }
  }
};
