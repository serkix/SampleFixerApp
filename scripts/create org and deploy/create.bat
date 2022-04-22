call sfdx force:org:create -f definition.json --setdefaultusername adminEmail=%1 username=%1.%2
call sfdx force:user:password:generate --targetusername %1.%2
call sfdx force:user:display -u %1.%2
cd ../..
call sfdx force:source:push --json --loglevel fatal --forceoverwrite -u %1.%2
call sfdx force:data:tree:import -f ./customSettings/export-credentials-FixerCredentials__c.json