---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
comments: false
---

# Cherry Pick

Given an existing commit on one branch, apply the change to another branch.

This can be useful for backporting bug fixes to previous release branches. Make
the commit on the default branch, and then cherry pick in to stable.

## Sample workflow

1. Check out a new 'stable' branch from the default branch.

   ```shell
   git checkout master
   git checkout -b stable
   ```

1. Change back to the default branch.

   ```shell
   git checkout master
   ```

1. Edit '`cherry_pick.rb`'.

1. Commit the changes.

   ```shell
   git add cherry_pick.rb
   git commit -m 'Fix bugs in cherry_pick.rb'
   ```

1. Review the commit log to get the commit SHA.

   ```shell
   git log
   ```

1. Check out the 'stable' branch.

   ```shell
   git checkout stable
   ```

1. Cherry pick the commit using the previously obtained SHA:

   ```shell
   git cherry-pick <commit SHA>
   ```
