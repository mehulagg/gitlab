---
stage: none
group: unassigned
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Preventing Transient Bugs

This page will cover architectural patterns and tips for developers to follow to prevent transient bugs.

## Frontend

### Don't rely on response order 

When working with multiple requests, it's easy to assume the order of the responses will match the order in which they are triggered.

That's not always the case and can cause bugs that only happen if the order is switched.

**Example:**

* diffs_metadata.json (lighter)
* diffs_batch.json (heavier)

If your feature requires data from both, ensure that the two have finished loading before working on it. 

### Simulate slower connetions when testing manually

Add a network condition template to your browser's dev tools to enable you to toggle between a slow and a fast connection.

**Example:**

* Turtle:
  * Down: 50kb/s
  * Up: 20kb/s
  * Latency: 10000ms

### Collapsed elements

When setting event listeners, if not possible to use event delegation, ensure all relevant event listeners are set for expanded content.

Including when that expanded content is: 

* **Invisible** (`display: none;`). Some javascript requires the element to be visible to work properly (eg.: when taking measurements).
* **Dynamic content** (AJAX/DOM manipulation).
