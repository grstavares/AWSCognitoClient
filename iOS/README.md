# CognitoAuthenticatio

## Dependencies

To test the application you must dowload the following AWS SDK Frameworks and add then to the CognitoAuthentication Folder:

- AWSAuthCore
- AWSCognitoIdentityProvider
- AWSCognitoIdentityProviderASF
- AWSCore
- AWSMobileClient

You can find more information about this frameworks in the official [AWS-SDK iOS Library](https://aws-amplify.github.io/docs/ios/manualsetup#frameworks-setup).

## Configuration

You also will need to create a file to configure your already existent AWS Cognito User Pool. The file should be names `awsconfiguration.json` and must have the following format:

```json
{
    "IdentityManager": {
        "Default": {}
    },
    "CognitoUserPool": {
        "Default": {
            "PoolId": "YOUR_USER_POOL_ID",
            "AppClientId": "YOUR_APP_CLIENT_ID",
            "AppClientSecret": "YOUR_APP_CLIENT_SECRET",
            "Region": "AWS_REGION"
        }
    }
}
```
