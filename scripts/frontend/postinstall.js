const chalk = require('chalk');

function setupSymlinkedGitLabUI() {
  // eslint-disable-next-line global-require
  const fs = require('fs');
  // eslint-disable-next-line global-require
  const path = require('path');
  const gitlabRoot = path.resolve(path.join(__dirname, '..', '..'));
  // TODO: This should exist
  const gitlabUISrc = path.join(gitlabRoot, '../gitlab-ui');
  const gitlabUIDir = path.join(gitlabRoot, 'node_modules/@gitlab/ui');

  console.log(chalk.green('GDK with GitLab UI in watch mode detected'));
  console.log('Setting up symlink');

  if (fs.existsSync(gitlabUIDir)) {
    const stat = fs.lstatSync(gitlabUIDir);
    if (stat.isSymbolicLink()) {
      console.log(`Already a symbolic link ${gitlabUIDir}`);
      return;
    }
    if (stat.isDirectory()) {
      fs.rm(gitlabUIDir, { recursive: true });
    }
  }
  fs.symlinkSync(gitlabUISrc, gitlabUIDir);

  // TODO: Force a webpack recompile
}

// check that fsevents is available if we're on macOS
if (process.platform === 'darwin') {
  try {
    require.resolve('fsevents');
  } catch (e) {
    console.error(`${chalk.red('error')} Dependency postinstall check failed.`);
    console.error(
      chalk.red(`
        The fsevents driver is not installed properly.
        If you are running a new version of Node, please
        ensure that it is supported by the fsevents library.

        You can try installing again with \`${chalk.cyan('yarn install --force')}\`
      `),
    );
    process.exit(1);
  }
}

console.log(`${chalk.green('success')} Dependency postinstall check passed.`);

if (process.env.GITLAB_UI_WATCH === 'true') {
  setupSymlinkedGitLabUI();
}
