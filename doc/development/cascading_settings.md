---
stage: Manage
group: Access
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Cascading Settings

The cascading settings framework allows groups to essentially inherit settings 
values from ancestors (parent group on up the group hierarchy) and from 
instance-level application settings. The framework also allows settings values
to be enforced on groups lower in the hierarchy. 

Cascading settings can currently only be defined within `NamespaceSetting`, though
the framework may be extended to other objects in the future.

## Add a new cascading setting

Settings are not cascading by default. The following steps outline how to define
a new cascading setting.

1. In `NamespaceSetting` model, define the new attribute using the `cascading_attr`
   helper method. This method accepts an array so multiple attributes can be defined
   on a single line.
   
    ```ruby
    class NamespaceSetting
      include CascadingNamespaceSettingAttribute
   
      cascading_attr :delayed_project_removal
    end
    ```

1. Create the necessary database migrations to satisfy the database structure
   requirements for cascading settings. See [example database migrations](#example-database-migrations) 
   for the migrations needed for a new cascading setting. 
   
    1. Columns in `namespace_settings` table:
        - `delayed_project_removal` column with no default value and with null values allowed. Use any column type.
        - `lock_delayed_project_removal` boolean column with default value of false and with null values not allowed.
    1. Columns in `application_settings` table:
        - `delayed_project_removal` column with type matching the column created in `namespace_settings`. 
          Set default value as desired and with null values not allowed. 
        - `lock_delayed_project_removal` boolean column with default value of false and with null values not allowed. 
        
## Convenience methods

By defining an attribute using the `cascading_attr` method, a number of convenience
methods are automatically defined. 

**Definition:**

```ruby
cascading_attr :delayed_project_removal
```

**Convenience Methods Available:**

- `delayed_project_removal`
- `delayed_project_removal=`
- `delayed_project_removal_locked?`
- `delayed_project_removal_locked_by_ancestor?`
- `delayed_project_removal_locked_by_application_setting?`
- `delayed_project_removal?` (only defined for boolean attributes)
- `delayed_project_removal_locked_ancestor` - Returns locked namespace settings object (only namespace_id)

The attribute reader method (`delayed_project_removal`) will return the correct
cascaded value using the following criteria:

1. Returns the dirty value, if the attribute has changed. This allows standard
   Rails validators to be used on the attribute, though `nil` values *must* be allowed. 
1. Return locked ancestor value.
1. Return locked instance-level application settings value.
1. Return this namespace's attribute, if not nil.
1. Return value from nearest ancestor where value is not nil.
1. Return instance-level application setting.
       
## Example database migrations

The following database migrations would be used for an entirely new setting. If
and existing setting is migrated to a cascading setting, different migrations 
would be necessary to move the column(s) to the required state. 

### Add columns to `namespace_settings`

```ruby
class AddDelayedProjectRemovalToNamespaceSettings < ActiveRecord::Migration[6.0]
  def change
    add_column :namespace_settings, :delayed_project_removal, :boolean
    add_column :namespace_settings, :lock_delayed_project_removal, :boolean, default: false, null: false
  end
end
```

### Add columns to `application_settings`

```ruby
class AddDelayedProjectRemovalToApplicationSettings < ActiveRecord::Migration[6.0]
  def change
    add_column :application_settings, :delayed_project_removal, :boolean, default: false, null: false
    add_column :application_settings, :lock_delayed_project_removal, :boolean, default: false, null: false
  end
end
```
