# How to try this source out
In order to deploy this code to scratch org:
1. Go to "scripts\create org and deploy" folder and open cmd there
2. Run create.bat command with 2 params initial user email and username postfix
For example
create.bat dummy@test.invalid deployOrgTest
Will create dummy@test.invalid.deployOrgTest user

Make sure that you have logged in SFDX
You may want to change fixer access token, feel free to do it by changing it in customSettings\export-credentials-FixerCredentials__c.json file