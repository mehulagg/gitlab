---
stage: Enablement
group: Memory
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Changing application settings cache expiry interval **(CORE ONLY)**

Application settings are cached for 60 seconds by default to reduce load on the database and Redis. While this
value would work well for most installations, there could be cases where you would want to adjust the interval value.

This interval value can be configured in `config/gitlab.yml`:

```plaintext
# application_settings_cache_seconds: 60
```

Uncomment and customize this line if you want to change the default value of the time to expire the application settings cache.
A higher value would mean a greater delay between changing an application setting and noticing that change come into effect.
A lower value could result in more load on the database and Redis depending on the amount data in the `application_settings` table.

## Changing the application settings cache expiry in Omnibus installations

Application settings cache expiry interval can be configured in Omnibus installations by adding
 the following linke to `/etc/gitlab/gitlab.rb`.

```ruby
gitlab_rails['application_settings_cache_seconds'] = 60
```

After adding the configuration parameter, reconfigure and restart your GitLab instance:

```shell
gitlab-ctl reconfigure
gitlab-ctl restart
```
