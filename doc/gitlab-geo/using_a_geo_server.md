# Using a Geo Server

After you set up the [database replication and configure the GitLab Geo nodes][req],
there are a few things to consider:

1. Users need an extra step to be able to fetch code from the secondary and push
   to primary:

     1. Clone the repository as you would normally do, but from the secondary node:

         ```bash
         git clone git@secondary.gitlab.example.com:user/repo.git
         ```

     1. Change the remote push URL to always push to primary, following this example:

         ```bash
         git remote set-url --push origin git@primary.gitlab.example.com:user/repo.git
         ```

[req]: README.md#setup-instructions
