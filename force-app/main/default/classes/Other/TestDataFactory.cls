@isTest
public with sharing class TestDataFactory {
    public static FixerCredentials__c createFixerCredentials() {
        FixerCredentials__c testCredentials = new FixerCredentials__c(
            AccessToken__c = 'MOCKDATA',
            BaseUrl__c     = 'http://data.fixer.io/api/',
            Name           = 'Production'
        );
        insert testCredentials;
        return testCredentials;
    }

    public static Trade__c createNewTrade() {
        Trade__c newTrade = new Trade__c(
            BuyAmount__c = 1,
            BuyCurrency__c = 'USD',
            DateBooked__c = datetime.now(),
            SellAmount__c = 1,
            SellCurrency__c = 'EUR',
            Rate__c = 1
        );
        insert newTrade;
        return newTrade;
    }

    public static Group fillTradeReviewersQueue() {

        // As we will run test with SeeAllData=true we don't have to create Queue
        Group Queue = [SELECT Id FROM Group WHERE type='Queue' AND Name=:'Trade reviewers' LIMIT 1];

        List<User> newUsers = createUsers(3);

        List<GroupMember> groupMembers = new List<GroupMember>();
        groupMembers.add(new GroupMember(UserOrGroupId = newUsers[0].Id, GroupId = Queue.Id));
        groupMembers.add(new GroupMember(UserOrGroupId = newUsers[1].Id, GroupId = Queue.Id));
        groupMembers.add(new GroupMember(UserOrGroupId = newUsers[2].Id, GroupId = Queue.Id));

        insert groupMembers;
        return Queue;
    }

    private static List<User> createUsers(Decimal usersNumber) {
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        String orgId = UserInfo.getOrganizationId();
        List<User> usersToCreate = new List<User>();
        for (Decimal i = 0; i < usersNumber; i++) {
            User newUser = new User(
                FirstName='Test',
                LastName='Test',
                Alias = 'tst',
                Email = 'test@test.invalid',
                Username = 'test@test.' + orgId + '.invalid' + i,
                ProfileId = profileId.id,
                TimeZoneSidKey = 'GMT',
                LanguageLocaleKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                LocaleSidKey = 'en_US'
            );
            usersToCreate.add(newUser);
        }
        insert usersToCreate;
        return usersToCreate;
    }
}
