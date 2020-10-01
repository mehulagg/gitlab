---
stage: Create
group: Source Code
info: "To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers"
type: concepts, howto
description: "Introduction to Git rebase, force-push, and resolving merge conflicts through the command line."
---

# Introduction to Git rebase

Before diving into this document, make sure you are familiar with using
[Git through the command line](../../gitlab-basics/start-using-git.md).

This guide helps you to get started with rebasing, force-pushing, and fixing
merge conflicts locally.

[Rebasing](https://git-scm.com/docs/git-rebase) is a very common operation in
Git. There are the following rebase options:

- [Regular rebase](#regular-rebase).
- [Interactive rebase](#interactive-rebase).

Git rebase re-writes the branch's commit history, therefore, it's safer to
back up your branch before rebasing to make sure you won't lose any changes.
For example, consider a feature branch called `my-feature-branch`:

1. Open your feature branch in the terminal:

   ```shell
   git checkout my-feature-branch
   ```

1. Checkout a new branch from it:

   ```shell
   git checkout -b my-feature-branch-backup
   ```

1. Go back to your original branch:

   ```shell
   git checkout my-feature-branch
   ```

Now you can safely rebase it.

## Regular rebase

With a regular rebase you can update your feature branch with the default
branch (or any other branch).
This is an important step for Git-based development strategies to make sure
the changes you're adding do not break any existing changes added to the
target branch after you created your feature branch.

For example, to update your branch `my-feature-branch` with `master`:

1. Checkout your feature branch:

   ```shell
   git checkout my-feature-branch
   ```

1. Rebase it against `master`:

   ```shell
   git rebase origin/master
   ```

When you do that, Git imports all the commits submitted to `master` after the
moment you created your feature branch until the present moment, and puts the
commits you have in your feature branch on top of all the commits imported from
`master`.

You can replace `master` with any other branch you want to rebase against, for
example, `release-10-3`. You can also replace `origin` with other remote
repositories, for example, `upstream`.

If there are [merge conflicts](#merge-conflicts), Git will prompt you to fix
them before continuing to rebase.
After rebasing, you'll need to [force-push](#force-push) changes to the remote
repository.

To learn more check Git's documentation on [rebasing strategies](https://git-scm.com/book/en/v2/Git-Branching-Rebasing).

CAUTION: **Warning:**
As `git rebase` re-writes the commit history, it **can be harmful** to do it in
shared branches. It can cause complex merge conflicts, hard to resolve. In
these cases, instead of rebasing your branch against the default branch,
consider pulling it instead (`git pull origin master`). It has a similar
effect without compromising the work of your contributors.

## Interactive rebase

You can use interactive rebase to modify commits. For example, amend a commit
message, squash commits (join multiple commits into one), edit or delete
commits, among other options. It is handy for changing past commits messages
as well as for organizing the commit history of your branch to keep it clean.

TIP: **Tip:**
If you want to keep the default branch commit history clean, you don't need to
manually squash all your commits before merging every merge request;
you can enable [Squash and Merge](../../user/project/merge_requests/squash_and_merge.md)
and GitLab will do it automatically.

When you want to change anything in recent commits, use interactive
rebase by passing the flag `--interactive` (or `-i`) to the rebase command.

For example, if you want to edit the latest 3 commits in your branch
(`HEAD~3`), run:

```shell
git rebase -i HEAD~3
```

Git outputs the latest 3 commits and describes all the interactive rebase
options you can use. The default option is `pick`, which maintains the commit
unchanged. Replace the keyword `pick` according to the operation you want to
perform in each commit. For example, if you want to squash them into one:

1. Press <kbd>i</kbd> in your keyboard to switch to editing mode.
1. Navigate with your keyboard arrows to edit the **second** commit keyword from
   `pick` to `squash` (or `s`). Do the same to the **third** commit.
   The first commit should be left **unchanged** (`pick`) as we want to squash
   the second and third into the first.
1. Press <kbd>esc</kbd> to leave the editing mode.
1. Type `:wq` to "write" (save) and "quit".
1. Git outputs the commit message so you have a chance to edit it:
   - All lines starting with `#` will be ignored and not included in the commit
   message. Everything else will be included.
   - To leave it as-is type `:wq`. To edit the commit message: switch to the
   editing mode, edit the commit message, leave the editing mode, and write
   and quit.
1. If you haven't pushed your commits to the remote branch before rebasing,
   push your changes normally. If you had pushed these commits already,
   [force-push](#force-push) instead.

Note that the steps for editing through the command line can be slightly
different depending on your operating system and the shell you're using.

See [Numerous undo possibilities in Git](numerous_undo_possibilities_in_git/index.md#with-history-modification)
for a deeper look into interactive rebase.

## Force-push

When you perform more complex operations, for example, squash commits, reset or
rebase your branch, you'll have to _force_ an update to the remote branch,
since these operations imply re-writing the commit history of the branch.
To force an update, pass the flag `--force` or `-f` to the `push` command. For
example:

```shell
git push --force origin my-feature-branch
```

Forcing an update is **not** recommended when you're working on shared
branches.

Alternatively, you can also pass the flag [`--force-with-lease`](https://git-scm.com/docs/git-push#Documentation/git-push.txt---force-with-leaseltrefnamegt)
instead. It is safer as it does not overwrite any work on the remote
branch if more commits were added to the remote branch by someone else:

```shell
git push --force-with-lease origin my-feature-branch
```

Note that, if the branch you want to force-push is [protected](../../user/project/protected_branches.md),
you will not be able to do so unless you unprotect it beforehand. Then you can
force-push and re-protect it again.

## Merge conflicts

As the Git version control system is based on comparing versions of a file
line-by-line, whenever a line changed in your branch coincides with the same
line changed in the target branch after you created your branch from, Git will
identify these changes as a merge conflict. To fix it, you need to choose
which version of that line you want to keep.

Most of conflicts can be [resolved through the GitLab UI](../../user/project/merge_requests/resolve_conflicts.md).

For more complex cases, there are various methods for resolving them. There are
also Git CLI apps very handy to help you visualize the differences.

As an example, to fix conflicts locally you can use the following method:

1. Open the terminal and check out your feature branch.
1. [Rebase](#regular-rebase) your branch against the target branch so Git
   prompts you with the conflicts:

   ```shell
   git rebase origin/master
   ```

1. Open the conflicting file in a code editor of your preference.
1. Look for the conflict markers:
   - It begins with the marker: `<<<<<<< HEAD`.
   - Follows the content with your changes.
   - The marker: `=======` indicates the end of your changes.
   - Follows the content of the latest changes in the target branch.
   - The marker `>>>>>>>` indicates the end of the conflict.
1. Edit the file: choose which version (before or after `=======`) you want to
   keep, then delete the portion of the content you don't want in the file.
1. Make sure you've deleted the markers then save the file.
1. Repeat the process if there are other conflicting files.
1. Stage your changes:

   ```shell
   git add .
   ```

1. Commit your changes:

   ```shell
   git commit -m "Fix merge conflicts"
   ```

1. Continue rebasing:

   ```shell
   git rebase --continue
   ```

1. [Force-push](#force-push) to your remote branch.

If you change your mind, you can run `git rebase --abort` to stop the process.
Git aborts rebasing and rolls back the branch to the state you had before
running `git rebase`.
