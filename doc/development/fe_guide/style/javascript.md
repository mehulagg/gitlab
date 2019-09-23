# JavaScript style guide

We use [Airbnb's JavaScript Style Guide](https://github.com/airbnb/javascript) and it's accompanying
linter to manage most of our JavaScript style guidelines.

In addition to the style guidelines set by Airbnb, we also have a few specific rules
listed below.

> **Tip:**
You can run eslint locally by running `yarn eslint`

## Avoid forEach

Avoid forEach when mutating data. Use `map`, `reduce` or `filter` instead of `forEach`
when mutating data. This will minimize mutations in functions,
which aligns with [Airbnb's style guide](https://github.com/airbnb/javascript#testing--for-real).

```javascript
// bad
users.forEach((user, index) => {
  user.id = index;
});

// good
const usersWithId = users.map((user, index) => {
  return Object.assign({}, user, { id: index });
});
```

## Limit number of parameters

If your function or method has more than 3 parameters, use an object as a parameter
instead.

```javascript
// bad
function a(p1, p2, p3) {
  // ...
};

// good
function a(p) {
  // ...
};
```

## Avoid side effects in constructors

Avoid making asynchronous calls, API requests or DOM manipulations in the `constructor`.
Move them into separate functions instead. This will make tests easier to write and
code easier to maintain.

```javascript
// bad
class myClass {
  constructor(config) {
    this.config = config;
    axios.get(this.config.endpoint)
  }
}

// good
class myClass {
  constructor(config) {
    this.config = config;
  }

  makeRequest() {
    axios.get(this.config.endpoint)
  }
}
const instance = new myClass();
instance.makeRequest();
```

## Avoid classes to handle DOM events

If the only purpose of the class is to bind a DOM event and handle the callback, prefer
using a function.

```javascript
// bad
class myClass {
  constructor(config) {
    this.config = config;
  }

  init() {
    document.addEventListener('click', () => {});
  }
}

// good

const myFunction = () => {
  document.addEventListener('click', () => {
    // handle callback here
  });
}
```

## Pass element container to constructor

When your class manipulates the DOM, receive the element container as a parameter.
This is more maintainable and performant.

```javascript
// bad
class a {
  constructor() {
    document.querySelector('.b');
  }
}

// good
class a {
  constructor(options) {
    options.container.querySelector('.b');
  }
}
```

## Use ParseInt

Use `ParseInt` when converting a numeric string into a number.

```javascript
// bad
Number('10')

// good
parseInt('10', 10);
```

## CSS Selectors - Use `js-` prefix

If a CSS class is only being used in JavaScript as a reference to the element, prefix
the class name with `js-`.

```html
// bad
<button class="add-user"></button>

// good
<button class="js-add-user"></button>
```

## Absolute vs relative paths for modules

Use relative paths if the module you are importing is less than two levels up.

```javascript
// bad
import GitLabStyleGuide from '~/guides/GitLabStyleGuide';

// good
import GitLabStyleGuide from '../GitLabStyleGuide';
```

If the module you are importing is two or more levels up, use an absolute path instead:

```javascript
// bad
import GitLabStyleGuide from '../../../guides/GitLabStyleGuide';

// good
import GitLabStyleGuide from '~/GitLabStyleGuide';
```

Additionally, **do not add to global namespace**.

## Do not use `DOMContentLoaded` in non-page modules

Imported modules should act the same each time they are loaded. `DOMContentLoaded`
events are only allowed on modules loaded in the `/pages/*` directory because those
are loaded dynamically with webpack.

## Avoid XSS

Do not use `innerHTML`, `append()` or `html()` to set content. It opens up too many
vulnerabilities.

## ESLint

### Disabling ESLint in new files

Do not disable ESLint when creating new files. Existing files may have existing rules
disabled due to legacy compatibility reasons but they are in the process of being refactored.

Do not disable specific ESLint rules. Due to technical debt, you may disable the following
rules only if you are invoking/instantiating existing code modules.

- [no-new](http://eslint.org/docs/rules/no-new)
- [class-method-use-this](http://eslint.org/docs/rules/class-methods-use-this)

> Note: Disable these rules on a per line basis. This makes it easier to refactor
> in the future. E.g. use `eslint-disable-next-line` or `eslint-disable-line`.

### Disabling ESLint for a single violation

If you do need to disable a rule for a single violation, try to do it as locally as possible

```javascript
// bad
/* eslint-disable no-new */

import Foo from 'foo';

new Foo();
```

```javascript
// better
import Foo from 'foo';

// eslint-disable-next-line no-new
new Foo();
```

### The `no-undef` rule and declaring globals

**Never** disable the `no-undef` rule. Declare globals with `/* global Foo */` instead.

When declaring multiple globals, always use one `/* global [name] */` line per variable.

```javascript
// bad
/* globals Flash, Cookies, jQuery */

// good
/* global Flash */
/* global Cookies */
/* global jQuery */
```

## IIFEs

Avoid using IIFE. Although we have a lot of examples of files which wrap their
contents in IIFEs (immediately-invoked function expressions),
this is no longer necessary after the transition from Sprockets to webpack.
Do not use them anymore and feel free to remove them when refactoring legacy code.

## The global namespace and side effects

Avoid adding to the global namespace.

```javascript
// bad
window.MyClass = class { /* ... */ };

// good
export default class MyClass { /* ... */ }
```

Side effects are forbidden in any script which contains export

```javascript
// bad
export default class MyClass { /* ... */ }

document.addEventListener("DOMContentLoaded", function(event) {
  new MyClass();
}
```

Avoid constructors with side-effects. Although we aim for code without side-effects we need some side-effects for our code to run.

If the class won't do anything if we only instantiate it, it's ok to add side effects into the constructor (_Note:_ The following is just an example. If the only purpose of the class is to add an event listener and handle the callback a function will be more suitable.)

```javascript
// Bad
export class Foo {
  constructor() {
    this.init();
  }
  init() {
    document.addEventListener('click', this.handleCallback)
  },
  handleCallback() {

  }
}

// Good
export class Foo {
  constructor() {
    document.addEventListener()
  }
  handleCallback() {
  }
}
```

On the other hand, if a class only needs to extend a third party/add event listeners in some specific cases, they should be initialized outside of the constructor.

## Data Mutation and Pure functions

1. Strive to write many small pure functions, and minimize where mutations occur.

   ```javascript
   // bad
   const values = {foo: 1};

   function impureFunction(items) {
     const bar = 1;

     items.foo = items.a * bar + 2;

     return items.a;
   }

   const c = impureFunction(values);

   // good
   var values = {foo: 1};

   function pureFunction (foo) {
     var bar = 1;

     foo = foo * bar + 2;

     return foo;
   }

   var c = pureFunction(values.foo);
    ```

1. Prefer `.map`, `.reduce` or `.filter` over `.forEach`.

   A forEach will most likely cause side effects, it will be mutating the array being iterated. Prefer using `.map`,
   `.reduce` or `.filter`

   ```javascript
   const users = [ { name: 'Foo' }, { name: 'Bar' } ];

   // bad
   users.forEach((user, index) => {
     user.id = index;
   });

   // good
   const usersWithId = users.map((user, index) => {
     return Object.assign({}, user, { id: index });
   });
   ```
