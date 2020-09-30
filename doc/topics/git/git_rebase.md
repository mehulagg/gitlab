---
stage: Create
group: Source Code
info: "To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers"
type: concepts, howto
description: "Introduction to Git rebase, force-push, and resolving merge conflicts through the command line."
---

# Git rebase

Before diving into this document, make sure you are familiar with [using Git through the command line](../../gitlab-basics/start-using-git.md).

[Rebasing](https://git-scm.com/docs/git-rebase) is a very common operation in
Git. You have mainly two rebase options:

- [Regular rebase](#regular-rebase).
- [Interactive rebase](#interactive-rebase).

## Regular rebase

With a regular rebase you can update your feature branch with the default
branch (or any other target branch).

This is an important step for Git-based development strategies to make sure
the changes you're adding do not break any existing changes added to the
target branch after you created your feature branch.

For example, to update your branch `my-feature-branch`, with `master`,
checkout your feature branch then rebase it against `master`:

```shell
git rebase origin/master
```

When you do that, Git imports all the commits submitted to `master` after the
moment you created your feature branch until the present moment, and puts the
commits you have in your feature branch on top of all the commits imported from
`master`.

If there are [merge conflicts](#merge-conflicts), Git will prompt you to fix
them before continuing to rebase.

After rebasing, you'll need to [force-push](#force-push) changes to the remote
repository.

To learn more check Git's documentation on [rebasing strategies](https://git-scm.com/book/en/v2/Git-Branching-Rebasing).

CAUTION: **Warning:**
As `git rebase` re-writes the commit history, it **can be harmful** to do it in
shared branches. It can cause complex merge conflicts, hard to resolve. In
these cases, instead of rebasing your branch against the default branch,
consider pulling it instead (`git pull origin master`). It will have a
similar effect without compromising the work of your contributors.

## Interactive rebase

You can use interactive rebase to amend a commit message, squash commits
(join multiple commits into one), edit, delete commits, among other actions. It is handy for
changing past commits messages and organizing the commit history of your
branch to keep it clean.

TIP: **Tip:**
If you want to keep the default branch commit history clean, you don't need to
do squash all your commits before merging manually for every merge request;
you can enable [Squash and Merge](../../user/project/merge_requests/squash_and_merge.md)
and GitLab will do it for you automatically.

When you want to change anything in recent commits, you can use interactive
rebase by passing the flag `--interactive` or `-i` to the rebase command.

For example, if you want to join the latest 2 commits in your branch, run:

```shell
git rebase -i HEAD~2
```

Then Git outputs the latest 2 commits. Edit the action you want for each of them:

1. Press <kbd>i</kbd> in your keyboard to switch to editing mode.
1. Navigate with your keyboard arrows to edit the second commit keyword from
   `pick` to `s`, which will squash both into one. The first commit will be
   picked and the second will be squashed into the first.
1. Press <kbd>esc</kbd> to leave the editing mode.
1. Type `:wq` to `write and quit`.
1. Git will output the commit message so you have a chance to edit it.

   All lines starting with `#` will be ignored and not included in the commit
   message. Everything else will be included.

   To leave it as-is type `:wq`, or, to edit the commit message, switch to the
   editing mode as you did on step 1-3, then write and quit when you're done.

1. If you haven't pushed your commits to the remote branch before rebasing,
push normally. If you had pushed these commits already, [force-push](#force-push) instead.

Note that the steps for editing through the command line can be slightly
different depending on your operating system and the terminal you're using.

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
instead. It can be safer not to overwrite any work on the remote
branch if more commits were added to the remote branch by someone else:

```shell
git push --force-with-lease origin my-feature-branch
```

Note that, if the branch you want to force-push is [protected](../../user/project/protected_branches.md),
you will not be able to do so unless you unprotect it beforehand. Then you can
force-push and re-protect it again.

## Merge conflicts

As Git version-control is based on comparing versions of a file line-by-line,
whenever a line changed in your branch coincides with the same line changed in
the target branch, Git will identify these changes as a merge conflict. This
means you need to choose which version of that line you want to keep.

Most of conflicts can be [resolved through the GitLab UI](../../user/project/merge_requests/resolve_conflicts.md).
For more complex cases, there are various methods for resolving them and
also Git CLI apps very handy to do so, but you can also fix them locally:

1. [Rebase your branch](#git-rebase) (`git rebase origin/master`) and Git will
   prompt you with the conflicts.
1. Open the conflicting file in a code editor of your preference.
1. Look for the conflict markers:
   - Beginning: `<<<<<<< HEAD`.
   - Content with your changes.
   - End of your changes: `=======`.
   - Content of the latest changes on the target branch.
   - End of the conflict `>>>>>>>`.
1. Edit the file: choose which version (before or after `=======`) you want to keep.
1. Make sure you've deleted the markers and save the file.
1. Repeat the process if there are other conflicting files.
1. Stage your changes (`git add .`).
1. Commit your changes (`git commit -m "Fix merge conflicts"`).
1. Continue rebasing with `git rebase --continue`.
1. [Force-push](#force-push) to your remote branch.
