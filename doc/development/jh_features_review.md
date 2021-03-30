---
stage: none
group: unassigned
info: https://gitlab.com/gitlab-jh/gitlab
---

# Guidelines for reviewing JiHu (JH) Edition features

- If needed, review the corresponding JH merge request located at <https://gitlab.com/gitlab-jh/gitlab>

## Act as EE when `jh/` does not exist

* In the case of EE repository, `jh/` does not exist so it should just act like EE (or CE when the license is absent)
* In the case of JH repository, `jh/` does exist but `EE_ONLY` environment variable can be set to force it run under EE mode.
* In the case of JH repository, `jh/` does exist but `FOSS_ONLY` environment variable can be set to force it run under CE mode.

## CI pipelines in a JH context

EE repository does not have `jh/` directory therefore there is no way to run
JH pipelines in the EE repository. All JH tests should go to [JH repository](https://gitlab.com/gitlab-jh/gitlab).

The top-level JH CI configuration is located at `jh/.gitlab-ci.yml` (which
does not exist in EE repository) and it'll include EE CI configurations
accordingly. Sometimes it's needed to update the EE CI configurations for JH
to customize more easily.

## Separation of JH code

All JH code should be put inside the `jh/` top-level directory. The
rest of the code should be as close to the EE files as possible.

### JH features based on CE or EE features

For features that build on existing CE/EE features, write a module in the `JH`
namespace and inject it in the CE/EE class, on the last line of the file that
the class resides in. This aligns what we're doing with EE features.

See [EE features based on CE features](ee_features#ee-features-based-on-ce-features) for more details.

For example, to prepend a module into the `User` class you would use
the following approach:

```ruby
class User < ActiveRecord::Base
  # ... lots of code here ...
end

User.prepend_ee_mod
User.prepend_jh_mod
```

Do not use methods such as `prepend`, `extend`, and `include`. Instead, use
`prepend_jh_mod`, `extend_jh_mod`, or `include_jh_mod`. These methods will
try to find the relevant JH module by the name of the receiver module.

If a corresponding EE extension is used, use the same one for JH to be
consistent.

Since the module would require an `JH` namespace, the file should also be
put in an `jh/` sub-directory.

If reviewing the corresponding JH file is needed, it should be found at
[JH repository](https://gitlab.com/gitlab-jh/gitlab).

### General guidance for writing JH extensions

See [Guidelines for implementing Enterprise Edition features](ee_features)
for general guidance.
