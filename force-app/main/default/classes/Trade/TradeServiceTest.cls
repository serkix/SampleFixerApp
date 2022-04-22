@isTest
public with sharing class TradeServiceTest {
    @isTest(SeeAllData=true)
    public static void testChatterPostCreation() {
        // GIVEN a Trade reviewers queue exists and has users in it
        TestDataFactory.fillTradeReviewersQueue();
        // WHEN creating a new trade
        test.startTest();
        Trade__c newTrade;
        System.RunAs(new User(Id = UserInfo.getUserId())) {
            newTrade = TestDataFactory.createNewTrade();
        }
        test.stopTest();

        // THEN chatter post should be created with mention comment
        List<FeedItem> chatterPosts = [SELECT Id, Body FROM FeedItem WHERE ParentId = :newTrade.Id];
        List<FeedComment> chatterComments = [SELECT Id, CommentBody FROM FeedComment WHERE FeedItemId = :chatterPosts[0].Id];
        System.assertNotEquals(0, chatterPosts.size(), 'Chatter post has not been created after trade creation');
        System.assertNotEquals(0, chatterComments.size(), 'Chatter comment with mention has not been created after trade creation');
    }
}
