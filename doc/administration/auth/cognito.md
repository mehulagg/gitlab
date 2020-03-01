# Amazon Web Services Cognito

Amazon Cognito lets you add user sign-up, sign-in, and access control to your GitLab quickly and easily.
The following documentation enables Cognito as an OAuth provider.

## Configure Cognito

To enable the [AWS Cognito](https://aws.amazon.com/cognito/) OAuth2 OmniAuth provider, you must register your application with Cognito, and generate a client id and secret key.
The following steps enable AWS Cognito as an authentication provider:

1. Sign in to the [AWS console](https://console.aws.amazon.com/console/home).
1. Select **Cognito** from the **Services** menu.
1. Select **Manage User Pools**, and click the **Create a user pool** button in the top right corner.
1. Enter the pool name and then click the **Step through settings** button.
1. Under **How do you want your end users to sign in?**, select **Email address or phone number** and **Allow email addresses**.
1. Under **Which standard attributes do you want to require?**, select **email**.
1. Go to the next steps of configuration and set the rest of the settings to suit your needs - in the basic setup they are not related to GitLab configuration.
1. In the **App clients** settings, click **Add an app client**, add **App client name** and select the **Enable username password based authentication** check box.
1. Click **Create app client**.
1. In the next step, you can set up lambdas for sending emails, such as welcome emails, and finish creating the pool. All settings can be changed later.
1. After creating the user pool, go to **App client settings** and provide the required information:

   - **Enabled Identity Providers** - select all
   - **Callback URL** - `https://gitlab.example.com/users/auth/cognito/callback`
   - **Allowed OAuth Flows** - Authorization code grant
   - **Allowed OAuth Scopes** - `email` and `openid`

1. Save changes for the app client settings.
1. Under **Domain name** setup domain for your Cognito.

## Configure GitLab

1. See [Initial OmniAuth Configuration](omniauth.md#initial-omniauth-configuration) for initial settings.
1. On your GitLab server, open the configuration file.

**For Omnibus installations**

   ```shell
   sudo editor /etc/gitlab/gitlab.rb
   ```

1. Add the provider configuration, replacing `CLIENT ID` and `CLIENT SECRET` with the values from **App clients** in Cognito:

   ```ruby
   gitlab_rails['omniauth_allow_single_sign_on'] = ['cognito']
   gitlab_rails['omniauth_providers'] = [
     {
       "name" => "cognito",
       "app_id" => "CLIENT ID",
       "app_secret" => "CLIENT SECRET",
       "args" => {
         client_options: {
           'site' => 'https://your_domain.auth.your_region.amazoncognito.com',
           'authorize_url' => '/login',
           'token_url' => '/oauth2/token',
           'user_info_url' => '/oauth2/userInfo'
         },
         user_response_structure: {
           root_path: [],
           attributes: { nickname: 'email'}
         },
         name: 'cognito',
         strategy_class: "OmniAuth::Strategies::OAuth2Generic"
       }
     }
   ]
   ```

1. Save the configuration file.
1. Save the file and [reconfigure] GitLab for the changes to take effect.

Your sign-in page should now display a Cognito button below the regular sign-in form. To begin the authentication process, click the icon, and AWS Cognito will ask the user to sign in and authorize the GitLab application. If successful, the user will be redirected back to GitLab, and signed in.

[reconfigure]: ../restart_gitlab.md#omnibus-gitlab-reconfigure
[restart]: ../restart_gitlab.md#installations-from-source
