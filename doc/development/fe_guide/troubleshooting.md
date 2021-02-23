---
stage: none
group: unassigned
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Troubleshooting

Running into a problem? Maybe this will help ¯\＿(ツ)＿/¯.

## Troubleshooting issues

### This guide doesn't contain the issue I ran into

If you run into a Frontend development issue that is not in this guide, please consider updating this guide with your issue and possible remedies. This way future adventurers can face these dragons with more success, being armed with your experience and knowledge.

## Testing issues

### ``Property or method `nodeType` is not defined`` but I'm not using `nodeType` anywhere

This issue can happen in Vue component tests, when an expectation fails, but there is an error thrown when
Jest tries to pretty print the diff in the console. It's been noted that using `toEqual` with an array as a
property might also be a contributing factor.

See [this video](https://youtu.be/-BkEhghP-kM) for an in-depth overview and investigation.

**Remedy - Try cloning the object that has Vue watchers**

```patch
- expect(wrapper.find(ChildComponent).props()).toEqual(...);
+ expect(cloneDeep(wrapper.find(ChildComponent).props())).toEqual(...)
```

**Remedy - Try using `toMatchObject` instead of `toEqual`**

```patch
- expect(wrapper.find(ChildComponent).props()).toEqual(...);
+ expect(wrapper.find(ChildComponent).props()).toMatchObject(...);
```

Please note that `toMatchObject` actually changes the nature of the assertion and won't fail if some items are **missing** from the expectation.

## Vue component mount issues

### When rendering a component that uses GlFilteredSearch and the component or its parent uses Vue Apollo

When trying to render our gitlab-ui component GlFilteredSearch, I was getting an error in the provide function:

`cannot read suggestionsListClass of undefined`

Apparently, vue-apollo will try to merge provide in the before create method, but when referencing props in the provide function, it doesnt seem to have access to either `this` or props.

This closed MR provides more context https://gitlab.com/gitlab-org/gitlab-ui/-/merge_requests/2019

#### Solution

Currently, it seems the best solution would be to contribute upstream to VueApollo. But if you come across this issue, it can be solved by adding an `apolloProvider: {}` to the component mount function. (We understand this is ideal but resolves the error temporarily)


