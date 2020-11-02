## Setup

1. Clone https://github.com/codesandbox/codesandbox-client
2. `cd` into directory
3. `asdf local nodejs 10.14.2`
4. `yarn global add lerna`
5. `yarn install`

## Building codesandbox packages locally

1. `cd standalone-packages/sandpack`
2. `yarn run build` to build the `./dist` assets imported in to the GitLab webpack bundle.
3. `yarn run prepublishOnly` to build the `./sandpack` assets that are served from the Sourcegraph sandpack host.

## Linking

In the `codesandbox-client` project, in the `standalone-packages/sandpack` directory, run `yarn link`.

In the GitLab project, run `yarn link "smooshpack"`

This way `yarn` will look for `smooshpack` **on disk** as opposed to the one in the package manager.

## Creating sandpack server

In the GitLab project, run

```
cd node_modules/smooshpack/sandpack
python -m http.server
```
