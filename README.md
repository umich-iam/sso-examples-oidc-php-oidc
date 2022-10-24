# Example PHP Application using JumboJett OpenID Connect library

The [jumbojett/OpenID-Connect-PHP](https://github.com/jumbojett/OpenID-Connect-PHP) git repository contains a sample application that demonstrates how to use this implementation of the OpenID Connect (OIDC) library in PHP.

To use this sample application in the U-M ITS Virtual Web Hosting environment, you will need to request a virtual host through the ITS Virtual Hosting service:

- [ITS Web Hosting Service](https://its.umich.edu/computing/web-mobile/web-hosting)

You will also need to obtain a SSL/TLS certificate for your site as your site should only support HTTPS (no insecure HTTP traffic).

- [Certificate Services](https://its.umich.edu/computing/web-mobile/certificate-services)

A full step-by-step explanation of how to obtain AFS space, a Virtual Host, SSL/TLS certificate, and DNS entry for your site are beyond the scope of this how-to.

After you have the above components created for you and configured, you can set up your site to use the sample application to exercise the jumbojett OpenID Connect PHP library via the following steps:

- Clone repo [jumbojett/OpenID-Connect-PHP](https://github.com/jumbojett/OpenID-Connect-PHP)

    `git clone https://github.com/jumbojett/OpenID-Connect-PHP.git`

- Copy client_example.php into your application's document root

    `cp OpenID-Connect-PHP/client_example.php [document root]/.`

- Obtain OIDC Service Client credentials

You can self-provision OIDC Service Client credentials using the "OIDC Provisioning and Management" (OPaM) tool as documented in the following ITS KNowledge Base article:

- [Provision OIDC Service Client Credentials](https://teamdynamix.umich.edu/TDClient/30/Portal/KB/ArticleDet?ID=8746)

For this example application, you should configure the `Redirect URI` to `https://my.site.url/client_example.php` (substitute `my.site.url` with the fully qualified domain name (FQDN) for your site) when you provision the OIDC Service Client credentials for your site.

- Modify the client_example.php code

There are currently a few issues with the default code in the [jumbojett/OpenID-Connect-PHP](https://github.com/jumbojett/OpenID-Connect-PHP) GitHub repository which require modifications to work correctly in the U-M ITS Virtual Web Hosting environment.

Currently, the code looks like this:

```linux
...
require __DIR__ . '/vendor/autoload.php';

use Jumbojett\OpenIDConnectClient;

$oidc = new OpenIDConnectClient(
    'http://myproviderURL.com/',
    'ClientIDHere',
    'ClientSecretHere'
);

$oidc->authenticate();
$name = $oidc->requestUserInfo('given_name');
...
```

The issues to address:

- You need to fill in the correct details for the `OpenIDConnectClient` call.  ClientID and ClientSecret are obtained via the self-provisioning process in the OPaM tool.  The correct Provider URL for U-M is 'https://shibboleth.umich.edu/'.

- The jumbojett library supports the Client Authentication method `client_secret_basic` by default.  The OPaM tool default is `client_secret_post` and does not yet allow the option of selecting another method when provisioning OIDC service client credentials.  There is a code change required to explicitly set the Client Authentication method to `client_secret_post`.

- Need to add explicit scopes (`openid email profile edumember`) to optimize for U-M OIDC environment, otherwise it will default to `openid` only.

The resulting code should look like this (note the ClientID and ClientSecret are obscured here and should be filled in with your site's actual values):

```linux
...
require __DIR__ . '/vendor/autoload.php';

use Jumbojett\OpenIDConnectClient;

$oidc = new OpenIDConnectClient(
    'https://shibboleth.umich.edu/',
    'XXXXXXXXXXXXXXXXXXXXXXXXXX',
    'YYYYYYYYYYYYYYYYYYYYYYYYYY'
);

$oidc->setTokenEndpointAuthMethodsSupported(['client_secret_post']);

$oidc->addScope('openid email profile edumember');

$oidc->authenticate();
$name = $oidc->requestUserInfo('given_name');
...
```


- Test

Navigate to `https://my.site.url/client_example.php` (substitute `my.site.url` with the fully qualified domain name (FQDN) for your site).  You should be automatically redirected to U-M Weblogin for single sign-on authentication.  Upon successful authentication, you should see `Hello uniqname` (where `uniqname` is your U-M username you authenticated as).

An example has been provided for demonstration purposes.  To use:
- replace `server.key` with a valid key
- replace `server.crt` with a valid web cert
- Fill in the variables in `docker-compose.env` with your OIDC Client ID and Secret
- `docker-compose build` or `docker compose build` (depending on which docker-compose you have installed)
- `docker-compose up -d` or `docker compose up -d` (depending, same as prior)

