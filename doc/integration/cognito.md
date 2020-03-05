# Amazon Web Services Cognito

To enable the AWS Cognito OAuth2 OmniAuth provider, you must register your application with Cognito, and generate a client id and secret key for you to use.
This instruction contains minimum settings which allow to bring it to work.

1. Sign in to the [AWS](https://console.aws.amazon.com/console/home).

1. Select **Cognito** from the **Services** menu.

1. Select **Manage User Pools**, and click the **Create a user pool** button in the top right corner.

1. Enter the pool name and then click the **Step through setting** button.

1. Select **Allow email addresses** from the second option.

1. Select **email** from standard attributes as required

1. Go to the next steps and set all other attributes as you need.

1. At the **App clients** settings add an app client and mark **Enable username password based authentication**. Create app.
![Cognito app](img/cognito_app.png)

1. In the next step, you can setup lambdas for sending emails, such as welcome emails, and finish creating the pool. All settings can be changed later.

1. After creating user pool go to **App client settings** and provide required information:

- **Enabled Identity Providers** - select all
- **Callback URL** - `https://gitlab.example.com/users/auth/cognito/callback`
- **Allowed OAuth Flows** - Authorization code grant
- **Allowed OAuth Scopes** - `email` and `openid`

1. Under **Domain name** setup domain for your Cognito.

1. On your GitLab server, open the configuration file.

   For Omnibus package:

   ```sh
   sudo editor /etc/gitlab/gitlab.rb
   ```

   For installations from source:

   ```sh
   cd /home/git/gitlab

   sudo -u git -H editor config/gitlab.yml
   ```

1. See [Initial OmniAuth Configuration](omniauth.md#initial-omniauth-configuration) for initial settings.

1. Add the provider configuration:

   For Omnibus package:

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

1. Replace 'CLIENT ID' and 'CLIENT SECRET' with the values from **App clients** in Cognito.

1. Save the configuration file.

1. [Reconfigure][] or [restart GitLab][] for the changes to take effect if you
   installed GitLab via Omnibus or from source respectively.

On the sign in page there should now be a Cognito button below the regular sign in form. Click the icon to begin the authentication process. AWS Cognito will ask the user to sign in and authorize the GitLab application. If everything goes well the user will be returned to GitLab and will be signed in.

[reconfigure]: ../administration/restart_gitlab.md#omnibus-gitlab-reconfigure
[restart GitLab]: ../administration/restart_gitlab.md#installations-from-source
