---
stage: 
group: 
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# GitLab quick start **(FREE)**

As you begin your onboarding journey with GitLab, we want you to have the tools and knowledge to be successful. This quick start guide has the steps you need to get started:

- [Authentication](#authentication)
- [Set up group and project hierarchy](#set-up-group-and-project-hierarchy)
- [Import project data](#import-projects)
- [GitLab instances - security best practices](#gitlab-instance-security)
- [Monitor GitLab](#monitor-gitlab)
- Back up GitLab
  - [Self-managed](#back-up-gitlab-self-managed)
  - [GitLab SaaS](#back-up-gitlab-saas)
- [Alternative backup strategies](#alternative-backup-strategies)
- Support information for:
  - [GitLab self-managed](#support-for-gitlab-self-managed)
  - [GitLab SaaS](#support-for-gitlab-saas)
- API introduction and rate limits for:
  - GitLab self-managed
  - GitLab SaaS
- Where to find additional training and support

Each section has a checklist you can use to keep track of the setup steps.

## Authentication

Authentication is the first step in making your installation secure and protecting your work.

### Authentication steps

1. **Choose a strong, secure password**. Bonus points if you generate and store it in a password management system.
1. **Enable two-factor authentication (2FA) for your account**. This one-time secret code is an additional safeguard that keeps intruders out—even if they have your password.
1. **Add a backup email**. Can't log into GitLab? Lost access to your primary email account? Our support team can use your back-up email to help you sign in fast.

### Authentication checklist

**All users**:
 
- **Save or print your recovery codes**. If you can't access your authentication device, these recovery codes allow you to log in to your GitLab account.
- **Add an SSH key to your profile**. You can generate new recovery codes as needed with SSH.
- **Enable personal access tokens**. When using 2FA, these tokens allow you to access the GitLab API.
 
**Administrators**:
 
- **Secure every user account**. Enforce 2FA for all users (this is highly recommended for self-managed administrators); otherwise, users must individually enable this protection.

## Set up group and project hierarchy
 
Organize your environment by configuring your groups and projects.
 
- **Projects**: Designate a home for your files and code or track and organize issues in a business category.
- **Groups**: Organize a collection of users or projects. Use these groups to quickly assign people and projects.
- **Permissions**: Define user access and visibility for your projects and groups.
 
See more about [the basics of groups and projects](https://www.youtube.com/watch?v=cqb2m41At6s).
 
### Manage Access
 
1. Determine the access your groups have to tools and projects:

   - Grant team access to a set of resources. Designate specific groups that contain subgroups/projects only and others that include users ("members") only. Then, assign your user groups to subgroups/projects.
   - Use case: Run multiple Agile teams with microservices. See more about [running multiple Agile teams](https://www.youtube.com/watch?v=VR2r1TJCDew).
   - Benefit: Add a group of users to a project with a single action.
   - Get started. Manage project access by team.
 
1. Sync group memberships via LDAP:

   - Automatically integrate your LDAP groups with GitLab Enterprise Edition (**self-managed only**).
   - Use case: Auto-sync GitLab group memberships with LDAP group members.
   - Benefit: Get more control over per-group user management.
   - Get started. See more about [synching groups with LDAP](../administration/auth/ldap/index.md#group-sync).
 
1. Implement a top-level structure:

   - Manage user access with inherited permissions. Use up to 20 levels of subgroups to organize both teams and projects. See more about [inherited permissions](../user/project/members/index.md#inherited-membership).
   - Use case: Align user access with business objectives. For example, align your teams, cost centers, and product lines by creating subgroups that act as categories.
   - Benefit: Give group members more control over project management.
   - Get started: [See nested category examples](../user/group/subgroups/index.md#overview).
 
### Project and group checklist
 
For administrators:
 
- Create a [new project](../gitlab-basics/create-project.md).
- Create a [new group](../user/group/index.md#create-a-group).
- [Add members](../user/group/index.md#add-users-to-a-group) to the group.
- Create a [new subgroup](../user/group/subgroups/index.md#creating-a-subgroup).
- [Add members](../user/group/subgroups/index.md#membership) to the subgroup.
- Enable [external authorization control](../user/admin_area/settings/external_authorization.md#configuration).
 
## Import projects

You may need to import projects from external sources like GitHub, Bitbucket, or another instance of GitLab. Many external sources can be imported into GitLab.

### Popular project imports

- **[GitHub Enterprise to self-managed GitLab](../integration/github.md#enabling-github-oauth)**: Enabling OAuth makes it easier for developers to find and import their projects.
- **[Bitbucket Server](../user/project/import/bitbucket_server.md#limitations)**: There are certain data limitations. For assistance with these data types, contact your GitLab account manager or GitLab Support about our professional migration services.

### Import migration checklist

- Review the [GitLab projects documentation](../user/project/index.md#project-integrations).
- Consider [repository mirroring](../user/project/repository/repository_mirroring.md)—an [alternative to project migrations](../ci/ci_cd_for_external_repos/index.md).
- Check out our [migration index](../user/project/import/index.md) for documentation on common migration paths.
- Schedule your project exports with our [import/export API](../api/project_import_export.md#schedule-an-export).

## GitLab instance security

Security is an important part of the onboarding process. Securing your instance protects your work and your organization.

### Security best practices

While this isn't an exhaustive list, following these steps give you a solid start for securing your instance.

- Use a long root password, stored in a vault.
- Install trusted SSL certificate and establish a process for renewal and revocation.
- [Configure SSH key restrictions](../security/ssh_keys_restrictions.md#restrict-allowed-ssh-key-technologies-and-minimum-length) per your organization's guidelines.
- [Disable new sign-ups](../user/admin_area/settings/sign_up_restrictions.md#disable-new-sign-ups).
- Require email confirmation.
- Set password length limit, configure SSO or SAML user management.
- Limit email domains if allowing sign-up.
- Require two-factor authentication (2FA).
- [Disable password authentication](../user/admin_area/settings/sign_in_restrictions.md#password-authentication-enabled) for Git over HTTPS.
- Set up [email notification for unknown sign-ins](../user/admin_area/settings/sign_in_restrictions.md#email-notification-for-unknown-sign-ins).
- Configure [user and IP rate limits](https://about.gitlab.com/blog/2020/05/20/gitlab-instance-security-best-practices/#user-and-ip-rate-limits).
- Limit [webhooks local access](https://about.gitlab.com/blog/2020/05/20/gitlab-instance-security-best-practices/#webhooks).
- Set [rate limits for protected paths](../user/admin_area/settings/protected_paths.md).

## Monitor GitLab

After you've established your basic setup, you're ready to review the GitLab monitoring services. Prometheus is our core performance monitoring tool.

### Monitor with Prometheus

- **Use case**: [Prometheus](../administration/monitoring/prometheus/index.md) captures [these GitLab metrics](../administration/monitoring/prometheus/gitlab_metrics.md#metrics-available). See more about our [bundled software metrics](../administration/monitoring/prometheus/index.md#bundled-software-metrics).
- **Benefit**: Unlike other monitoring solutions (for example, Zabbix, New Relic), Prometheus is tightly integrated with GitLab and has extensive community support.
- **Get started**: Prometheus and its exporters are on by default; however, you need to [configure the service](../administration/monitoring/prometheus/index.md#configuring-prometheus). 

### Monitor key components

- [**Web servers**](../administration/monitoring/prometheus/gitlab_metrics.md#puma-metrics): Handles server requests and facilitates other back-end service transactions. Monitor CPU, memory, and network IO traffic to track the health of this node. 
- [**Workhorse**](../administration/monitoring/prometheus/gitlab_metrics.md#metrics-available): Alleviates web traffic congestion from the main server. Monitor latency spikes to track the health of this node. 
- [**Sidekiq**](../administration/monitoring/prometheus/gitlab_metrics.md#sidekiq-metrics): Handles background operations that allow GitLab to run smoothly. Monitor for long, unprocessed task queues to track the health of this node.

### Your performance checklist

- Learn more about [GitLab architecture](../development/architecture.md).
- Find out why [application performance metrics](https://about.gitlab.com/blog/2020/05/07/working-with-performance-metrics/) matter. 
- Create a [self-monitoring project](../administration/monitoring/gitlab_self_monitoring_project/index.md) to track the health of your instance.
- Integrate Grafana to [build visual dashboards](https://youtu.be/f4R7s0An1qE) based on performance metrics.

## Back up your GitLab data

GitLab provides backup methods to keep your data safe and recoverable. Whether you use a self-managed or a GitLab SaaS database, it's crucial to keep your data backed up regularly.

### Back up GitLab self-managed

- **Use Case**: Backing up an Omnibus (single node) GitLab server.
- **Benefit**: A single Rake task takes care of the whole backup process for you. There is a different routine depending on whether you deployed with Omnibus or the Helm chart.
- **Get Started**:  
   1. Read about [backing up Omnibus or Helm variations](../raketasks/backup_restore.md#back-up-gitlab).
   1. This process backs up your entire instance, but does not back up the configuration files. Ensure those are backed up separately.
   1. Keep your configuration files and backup archives in a separate location to ensure the encryption keys are not kept with the encrypted data.

### Restore a backup

- **Use Case**: Know how to quickly restore a GitLab backup, and ensure your backup archives have been verified.
- **Benefits**: Restoring a GitLab server is fast and reliable. Have confidence in your archives and the process.
- **Get Started**:  
   1. You can only restore a backup to **exactly the same version and type** (Community Edition/Enterprise Edition) of GitLab on which it was created.
   1. Review the [Omnibus backup and restore documentation](https://docs.gitlab.com/omnibus/settings/backups).
   1. Review the [Helm Chart backup and restore documentation](https://docs.gitlab.com/charts/backup-restore).

### Back up GitLab SaaS

Backups of GitLab databases and filesystems are taken every 24 hours, and are kept for two weeks on a rolling schedule. All backups are encrypted.

- GitLab SaaS creates backups to ensure your data is secure, but you can't use these methods to export or back up your data yourself.
- Issues are stored in the database. They can't be stored in Git itself.
- You can use either:
  - The [Project Export option using the UI](../user/project/settings/import_export.md#exporting-a-project-and-its-data).
  - The [Project Export option using the API](../api/project_import_export.md#schedule-an-export).
- Group Export does *not* export the projects in it, but does export:
  - Epics
  - Milestones
  - Boards
  - Labels
  - Additional items

 For more information about the import and export process, see the [Group import/export page](../user/group/settings/import_export.md#).

For more information about GitLab SaaS backups, see our [Backup FAQ page](https://about.gitlab.com/handbook/engineering/infrastructure/faq/#gitlabcom-backups).

### Alternative backup strategies

In some situations the Rake task for backups may not be the most optimal solution. Here are some alternatives to consider if the Rake task does not work for you.

#### **Option 1 - File system snapshot**

If your GitLab server contains a lot of Git repository data, you may find the GitLab backup script to be too slow. It can be especially slow when backing up to an offsite location.

This starts typically at a Git repository data size of around 200GB. In this case, you may consider using file system snapshots as part of your backup strategy.

For example, consider a GitLab server with the following components:

- Using Omnibus GitLab
- Hosted on AWS with an EBS drive containing an ext4 file system mounted at ```/var/opt/gitlab```

The EC2 instance meets the requirements for an application data backup by taking an EBS snapshot. The backup includes all repositories, uploads, and PostgreSQL data.

In general, if you're running GitLab on a virtualized server, you can likely create VM snapshots of the entire GitLab server. Note that it is common for a VM snapshot to require you to power down the server.

You can find more details and examples on our [Alternative backup strategies page](../raketasks/backup_restore.md).

#### **Option 2 - GitLab Geo**

Geo provides local, read-only instances of your GitLab instances.

While GitLab Geo helps remote teams work more efficiently by using a local GitLab node, it can also be used as a disaster recovery solution. See more about using [Geo as a disaster recovery solution](../administration/geo/disaster_recovery/index.md).

Geo replicates your database, your Git repositories, and a few other assets. GitLab is expanding support and replication of more data in the future. 

Find more information about [replication limitations](../administration/geo/replication/datatypes.md#limitations-on-replicationverification).

### Your backup checklist

- Decide on a backup strategy.
- Consider writing a cron job to make daily backups.
- Separately backup the configuration files.
- Decide what should be left out of the backup.
- Decide where to upload the backups.
- Limit backup lifetime.
- Run a test backup and restore.
- Set up a way to periodically verify the backups.

## Support for GitLab self-managed

GitLab provides support for self-managed GitLab through different channels.

- **Priority support**: Premium and Ultimate self-managed customers receive priority support with tiered response times. Learn more about [upgrading to priority support](https://about.gitlab.com/support/#upgrading-to-priority-support). 
- **Live upgrade assistance**: Get one-on-one expert guidance during a production upgrade. With your **priority support plan**, you're eligible for a live, scheduled screen-sharing session with a member of our support team.

### Your GitLab self-managed support checklist

- Access [GitLab Docs](../README.md) for self-service support.
- Join the [GitLab Forum](https://forum.gitlab.com/) for community support.
- Gather [your subscription information](https://about.gitlab.com/support/#for-self-managed-users) before submitting a ticket.
- [Submit a support ticket](https://support.gitlab.com/hc/en-us/requests/new).

## Support for GitLab SaaS

If you use GitLab SaaS, you have several channels with which to get support and find answers.

- **Priority support**: Gold and Silver GitLab SaaS customers receive priority support with tiered response times. Learn more about [upgrading to priority support](https://about.gitlab.com/support/#upgrading-to-priority-support). 
- **GitLab SaaS 24/7 monitoring**: Our full team of site reliability and production engineers is always on. Often, by the time you notice an issue, someone's already looking into it.

### Your GitLab SaaS support checklist

- Access [GitLab Docs](../README.md) for self-service support.
- Join the [GitLab Forum](https://forum.gitlab.com/) for community support.
- Gather [your subscription information](https://about.gitlab.com/support/#for-self-managed-users) before submitting a ticket.
- Submit a support ticket for:

  - [General assistance](https://support.gitlab.com/hc/en-us/requests/new?ticket_form_id=334447)
  - [Account or sign-in issues](https://support.gitlab.com/hc/en-us/requests/new?ticket_form_id=360000803379)
- Subscribe to [our status page](https://status.gitlab.com/) for the latest on GitLab performance or service interruptions.

## Additional links

- [Members](../user/project/members/index.md)
- [Groups](../user/group/index.md)
- [User account options](../user/profile/index.md)
- [SSH keys](../ssh/README.md)
- [GitLab.com settings](../user/gitlab_com/index.md)
