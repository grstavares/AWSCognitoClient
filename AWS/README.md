# AWS Cognito User Pool

Here will find a cloud formation template to create a User Pool to be used to test the Client Implementation.

## Resource Creation

To create the user pool you'll need a configured aws cli environment. In that environment, please run:

`aws cloudformation create-stack --stack-name STACK_NAME --template-body file://cognito-user-pool.cf.json --capabilities CAPABILITY_IAM`

You can check the Stack creation status using the following command:

`aws cloudformation describe-stacks --stack-name CognitoPOC`

After the Stack is created, recover from the Stack Description the following output values to cnfigure your Cognito Clients:

- UserPoolId
- UserPoolClientId
- IdentityPoolId

## Functionalities Description

During the user SignUp the user pool, as described in this template, will request the email and phone from the user. Booth values will be validated by Cognito before confirming the user registration.

By default the User Pool will validate the User Password creation using the following criteria:

- at least 8 characters
- must have uppercase letters
- must have lowercase letters
- must have at least 1 special character
- must have at least 1 number

## Permissions

To create the Cognito User Pool the user that is executing the aws cli command must have the following permissions:

- [Create/Update/Delete CloudFormation Stack](allow-cloudformation.json)
- [Create/Update/Delete Cognito User Pools](allow-cognito-userpool.json)
- [Create/Update/Delete Cognito Identity Pools](allow-cognito-identity.json)
