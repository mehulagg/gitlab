---
stage: none
group: unassigned
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Troubleshooting

Running into a problem? Maybe this guide can help

## Troubleshooting issues

If you ran into an issue that isn't in this guide, please consider updating this guide so future adventurers can be well equipped with your experience and knowledge.

## Testing issues

### ``Property or method `nodeType` is not defined`` but I'm not using `nodeType` anywhere

Is this issue coming up in a Vue component test? If so, you might be running into this very strange issue:

https://youtu.be/-BkEhghP-kM

This issue can happen when an expectation fails but there's an error generating the pretty printed diff in
the console. It's been noted that using `toEqual` with an array as a property might also be a contributing factor.

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
