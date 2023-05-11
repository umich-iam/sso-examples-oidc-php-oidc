<?php

require __DIR__ . '/../vendor/autoload.php';

use Jumbojett\OpenIDConnectClient;

$oidc_idp = 'https://weblogin.umich.edu/';
$oidc_client_id = getenv('OIDC_CLIENT_ID');
$oidc_client_secret = getenv('OIDC_CLIENT_SECRET');

$oidc = new OpenIDConnectClient($oidc_idp, $oidc_client_id, $oidc_client_secret);
$oidc->setTokenEndpointAuthMethodsSupported(['client_secret_post']);
$oidc->addScope('openid email profile edumember');
$oidc->authenticate();

$name = $oidc->requestUserInfo('given_name');

?>

<html>
<head>
    <title>Example OpenID Connect Client Use</title>
    <style>
        body {
            font-family: 'Lucida Grande', Verdana, Arial, sans-serif;
        }
    </style>
</head>
<body>
    <h1><?php print("Hello ". $name); ?></h1>
</body>
</html>

