---
stage: none
group: unassigned
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Backend directory structure

## Use namespaces to define bounded contexts

A healthy application is divided into macro and sub components that represent the contexts at play,
whether they are related to business domain or infrastructure code.

As GitLab code becomes broad with so many features and components it's hard to see what contexts are involved.
We should expect any class to be defined inside a module/namespace that represents the contexts where it operates.

The lack of namespaces makes large parts of the codebase to have a flat structure:
- Class names from different domains may be confused because X may mean something in one
  domain and something else in another domain.
- It's hard to understand which group is responsible for the direction of a particular
  component (domain experts).
- It's hard to understand the interactions between components.

```ruby
# bad
class MyClass
end

# good
module MyDomain
  class MyClass
  end
end
```
