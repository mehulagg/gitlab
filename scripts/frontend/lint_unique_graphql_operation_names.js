#!/usr/bin/env node
const path = require('path');
const fs = require('fs');
const chalk = require('chalk');
const GraphQLLanguage = require('graphql/language');
const glob = require('glob');

const rootDir = path.join(__dirname, '../..');

const files = glob.sync('{ee/,}app/**/*.graphql', { cwd: rootDir });

const operationNameMap = {};

const counts = {
  warn: 0,
  error: 0,
  total: 0,
};

const prefix = {
  warn: chalk.yellow('warning'),
  error: chalk.red('error'),
};

const messageMap = {};

const createMessage = type => (filePath, message) => {
  if (!messageMap[filePath]) {
    messageMap[filePath] = {
      filePath,
      messages: [],
    };
  }
  counts[type] += 1;
  counts.total += 1;
  messageMap[filePath].messages.push({ type, message });
};

const linter = {
  warn: createMessage('warn'),
  error: createMessage('error'),
};

files.forEach(relPath => {
  const filePath = path.join(rootDir, relPath);
  const contents = fs.readFileSync(filePath, 'utf-8');

  try {
    const parsed = GraphQLLanguage.parse(contents);

    for (const { kind, name } of parsed.definitions) {
      if (!(name && name.value)) {
        linter.warn(relPath, `${kind} is missing Operation Name`);
        continue;
      }

      const key = `${kind}:${name.value}`;

      if (!operationNameMap[key]) {
        operationNameMap[key] = {
          kind,
          name: name.value,
          paths: [],
        };
      }

      operationNameMap[key].paths.push(relPath);
    }
  } catch (e) {
    linter.error(filePath, 'Could not parse file. Is it a valid GraphQL file?');
  }
});

for (const { paths, kind, name } of Object.values(operationNameMap)) {
  if (paths.length > 1) {
    paths.forEach(filePath => {
      linter.warn(filePath, `Duplicate Operation Name '${name}' for '${kind}'`);
    });
  }
}

Object.keys(messageMap)
  .sort()
  .forEach(key => {
    const { messages, filePath } = messageMap[key];
    console.log(chalk.underline(filePath));
    messages.forEach(({ type, message }) => {
      console.log(`\t${prefix[type]} ${message}`);
    });
    console.log('\n');
  });

if (counts.total) {
  console.log(
    `Checked ${files.length} files, found ${counts.total} problems: ` +
      [counts.warn ? `${counts.warn} warnings` : '', counts.error ? `${counts.error} errors` : '']
        .filter(Boolean)
        .join(', '),
  );
} else {
  console.log(`Checked ${files.length} files. No problems found.`);
}

if (counts.error) {
  process.exit(1);
}
