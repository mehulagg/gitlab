---
stage: Configure
group: Configure
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Run the Kubernetes Agent locally **(PREMIUM SELF)**

You can run `kas` and `agentk` locally to test the [Kubernetes Agent](index.md) yourself.

1. Create a `cfg.yaml` file from the contents of
   [`config_example.yaml`](https://gitlab.com/gitlab-org/cluster-integration/gitlab-agent/-/blob/master/pkg/kascfg/config_example.yaml), or this example:

   ```yaml
   agent:
    listen:
       network: tcp
       address: 127.0.0.1:8150
       websocket: false
     gitops:
       poll_period: "10s"
   gitlab:
     address: http://localhost:3000
     authentication_secret_file: /Users/tkuah/code/ee-gdk/gitlab/.gitlab_kas_secret
   ```

1. Create a `token.txt`. This is the token for
   [the agent you created](../../user/clusters/agent/index.md#create-an-agent-record-in-gitlab). This file must not contain a newline character. You can create the file with this command:

   ```shell
   echo -n "<TOKEN>" > token.txt
   ```

1. Start the binaries with the following commands:

   ```shell
   # Need GitLab to start
   gdk start
   # Stop GDK's version of kas
   gdk stop gitlab-k8s-agent

   # Start kas
   bazel run //cmd/kas -- --configuration-file="$(pwd)/cfg.yaml"
   ```

1. In a new terminal window, run this command to start `agentk`:

   ```shell
   bazel run //cmd/agentk -- --kas-address=grpc://127.0.0.1:8150 --token-file="$(pwd)/token.txt"
   ```

You can also inspect the
[Makefile](https://gitlab.com/gitlab-org/cluster-integration/gitlab-agent/-/blob/master/Makefile)
for more targets.

<i class="fa fa-youtube-play youtube" aria-hidden="true"></i>
To learn more about how the repository is structured, see
[GitLab Kubernetes Agent repository overview](https://www.youtube.com/watch?v=j8CyaCWroUY).

## Run tests locally

You can run all tests, or a subset of tests, locally.

- **To run all tests**: Run the command `make test`.
- **To run all test targets in the directory**: Run the command
  `bazel test //internal/module/gitops/server:all`.

  You can use `*` in the command, instead of `all`, but it must be quoted to
  avoid shell expansion: `bazel test '//internal/module/gitops/server:*'`.
- **To run all tests in a directory and its subdirectories**: Run the command
  `bazel test //internal/module/gitops/server/...`.

### Run specific test scenarios

To run only a specific test scenario, you need the directory name and the target
name of the test. For example, to run the tests at
`internal/module/gitops/server/module_test.go`, the `BUILD.bazel` file that
defines the test's target name lives at `internal/module/gitops/server/BUILD.bazel`.
In the latter, the target name is defined like:

```bazel
go_test(
    name = "server_test",
    size = "small",
    srcs = [
        "module_test.go",
```

The target name is `server_test` and the directory is `internal/module/gitops/server/`.
Run the test scenario with this command:

```shell
bazel test //internal/module/gitops/server:server_test
```

### Additional resources

- Bazel documentation about [specifying targets to build](https://docs.bazel.build/versions/master/guide.html#specifying-targets-to-build).
- [The Bazel query](https://docs.bazel.build/versions/master/query.html)
- [Bazel query how to](https://docs.bazel.build/versions/master/query-how-to.html)

## QA Tests

# Tested successfully against staging ✅

## How to test against `staging` directly from your GDK instance:

**STEP 0** - (CAVEAT) Go to your local `qa/qa/service/cluster_provider/k3s.rb` and comment out [this line](https://gitlab.com/gitlab-org/gitlab/-/blob/5b15540ea78298a106150c3a1d6ed26416109b9d/qa/qa/service/cluster_provider/k3s.rb#L8) and [this line](https://gitlab.com/gitlab-org/gitlab/-/blob/5b15540ea78298a106150c3a1d6ed26416109b9d/qa/qa/service/cluster_provider/k3s.rb#L36)

Resons for this:
- We don't want to allow local connections on `staging`
- We wouldn't be able to do it anyway since we're going to test it with a non-admin user
- I think this was only used for GDK and Omnibus tests. But I'm proposing that we completely stop doing this as this won't be necessary once the QA tunnel is back and is not necessary locally for GDK with the use of a hostname instead of `localhost` in your `/etc/hosts`.
---

1. Go to GitLab's root folder and `cd qa`
1. Login with your own user in staging and create a group to be used as sandbox, for me I did: `jcunha-qa-sandbox`
1. Create an access token for your user with the `api` permission.
1. Run the following command, replacing the curly braces comments and cross your fingers:

```shell
GITLAB_SANDBOX_NAME="{THE GROUP ID YOU CREATED ON STEP 2}" \
GITLAB_QA_ACCESS_TOKEN="{THE ACCESS TOKEN YOU CREATED ON STEP 3}" \
GITLAB_USERNAME="{YOUR STAGING USERNAME}" \
GITLAB_PASSWORD="{YOUR STAGING PASSWORD}" \
bundle exec bin/qa Test::Instance::All https://staging.gitlab.com -- --tag quarantine qa/specs/features/ee/api/7_configure/kubernetes/kubernetes_agent_spec.rb
```

## How to test against your GDK instance:

**STEP 0** - (CAVEAT) Go to your `qa/qa/fixtures/kubernetes_agent/agentk-manifest.yaml.erb` and comment out [this line](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/49053/diffs#81111e16630bc859ec482eae4c8520af4e36d018_0_27) and UNcomment [this line](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/49053/diffs#81111e16630bc859ec482eae4c8520af4e36d018_0_28)

Reasons for this:
- In GDK `gitlab-kas` is listening on `grpc` not `wss`.
- We will automate this identification once we have https://gitlab.com/gitlab-org/gitlab/-/issues/292935
---

1. [Enable the `gitlab-k8s-agent` on your GDK](https://gitlab.com/gitlab-org/gitlab-development-kit/-/blob/master/doc/howto/kubernetes_agent.md).
1. Go to GitLab's root folder and `cd qa`
1. In GDK we can run as admin, which will be the default choice of the test. So we can use the default sandbox group So simply run:

```shell
bundle exec bin/qa Test::Instance::All http://gdk.test:3000 -- --tag quarantine qa/specs/features/ee/api/7_configure/kubernetes/kubernetes_agent_spec.rb
````

---

## Troubleshooting

- If you had `k3d` instance running before this, you might see a message saying something like `failed to remove k3s cluster`. If that's the case, stop you K3d manually and re-run the test.
- If your test is failing on the login screen, make sure you're passing the correct credentials.
- If your test test agains GDK is failing to provision a license, so breaking on `qa/qa/ee/resource/license.rb`, you probably changed your GDK admin user/password. You can set it by using this environment vars: `GITLAB_ADMIN_USERNAME` and `GITLAB_ADMIN_PASSWORD`.
- When testing against staging, you shouldn't have a `EE_LICENSE` env var set, since this would force a login admin login.
- Make sure FF is enabled: 
