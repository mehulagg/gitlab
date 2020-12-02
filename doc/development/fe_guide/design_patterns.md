---
stage: none
group: unassigned
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Design Patterns

The following design patterns are suggested approaches for solving common problems you might run into. Use discretion when evaluating
if a certain pattern makes sense in your situation. Just because it's a pattern doesn't mean it's a good fit in a certain context.

When adding a design pattern to this document, be sure to clearly explain the **problem it solves**.

## TBD

# Design Anti-patterns

The following patterns may seem like good ideas, but it's been shown that these bring more ills than benefits and should
generally be avoided. Any effort to remove these anti-patterns from the codebase is much appreciated!

**NOTE:** These anti-patterns are not **prohibited**, but it is strongly suggested to find another approach.

## Singleton (Anti-pattern)

The classic [Singleton pattern](https://en.wikipedia.org/wiki/Singleton_pattern) is a way of ensuring that only one instance of a 
thing can exist.

Here's a classic example of this pattern:

```javascript
class MyThing {
  constructor() {
    // ...
  }

  // ...
}

MyThing.instance = null;

export const getThingInstance = () => {
  if (MyThing.instance) {
    return MyThing.instance;
  }

  const instance = new MyThing();
  MyThing.instance = instance;
  return instance;
};
```

Here's an example of a Vuex Store singleton:

```javascript
const createStore = () => new Vuex.Store({
  actions,
  state,
  mutations
});

// Notice that we are forcing of this module to all use the same single instance of the store.
// As an alternative, we should simply export the `createStore` and let the client manage the
// lifecycle and instance of the store.
export default createStore();
```

Here are some historic examples where this pattern has brought various ills:

- https://gitlab.com/gitlab-org/gitlab/-/merge_requests/36401
- https://gitlab.com/gitlab-org/gitlab/-/merge_requests/30398#note_331174190
- https://gitlab.com/gitlab-org/gitlab-vscode-extension/-/merge_requests/97#note_417515776
- https://gitlab.com/gitlab-org/gitlab/-/merge_requests/36952
- https://gitlab.com/gitlab-org/gitlab/-/merge_requests/29461#note_324585814

**What problems do Singletons cause?**

1. Singletons encourage high coupling where clients of a class reference the specific class 
   instance rather than being passed an instance through a constructor or argument.
1. It's a big assumption that only 1 of something should ever exist. Once a singleton is
   introduced, because of the coupling it creates, it's hard to unravel.
1. Singleton factories are non-deterministic which can create non-deterministic situations
   in tests and production.
1. Singleton's can create side-effects which are never properly disposed because there's no
   clear "owner" of the resource.

**But then, why are Singletons so common in other languages like Java?**

This is because of the limitations of languages like Java where everything has to be wrapped
in a class. In JavaScript we have things like object and function literals where we can solve
many problems with a module that simply exports utility functions.
