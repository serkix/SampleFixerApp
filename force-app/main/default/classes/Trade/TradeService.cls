/**
 * @description The service class for Trade records
 */
public with sharing class TradeService {
    /* COLLECTIONS */

    private List<Trade__c> recordsNew { get; set; }
    private List<Trade__c> recordsOld { get; set; }
    private Map<Id, Trade__c> recordsNewById { get; set; }
    private Map<Id, Trade__c> recordsOldById { get; set; }

    /* TRIGGER HANDLERS */

    public void handleTrigger() {
        this.recordsOld = (List<Trade__c>) Trigger.old;
        this.recordsNew = (List<Trade__c>) Trigger.new;
        this.recordsOldById = (Map<Id, Trade__c>) Trigger.oldMap;
        this.recordsNewById = (Map<Id, Trade__c>) Trigger.newMap;

        if (Trigger.isBefore) {
            if (Trigger.isInsert) {
                onBeforeInsert();
            } else if (Trigger.isUpdate) {
                onBeforeUpdate();
            } else if (Trigger.isDelete) {
                onBeforeDelete();
            }
        } else if (Trigger.isAfter) {
            if (Trigger.isInsert) {
                onAfterInsert();
            } else if (Trigger.isUpdate) {
                onAfterUpdate();
            } else if (Trigger.isDelete) {
                onAfterDelete();
            }
        }
    }

    // before

    /**
     * @description Executes the before insert logic.
     */
    private void onBeforeInsert() {
    }

    /**
     * @description Executes the before update logic.
     */
    private void onBeforeUpdate() {
    }

    /**
     * @description Executes the before delete logic.
     */
    private void onBeforeDelete() {
    }

    // after

    /**
     * @description Executes the after insert logic.
     */
    private void onAfterInsert() {
        sendChatterPosts(this.recordsNew);
    }

    /**
     * @description Executes the after update logic.
     */
    private void onAfterUpdate() {
    }

    /**
     * @description Executes the after delete logic.
     */
    private void onAfterDelete() {
    }

    /* METHODS */
    private void sendChatterPosts(List<Trade__c> trades) {
        // Generate new Posts
        List<FeedItem> newPosts = new List<FeedItem>();
        for (Trade__c trade : trades) {
            newPosts.add(createChatterPostForTrade(trade));
        }
        insert newPosts;
        // Add comments with mentions to those posts
        List<User> usersToMention = getQueueUsers('Trade reviewers');

        for (FeedItem post : newPosts) {
            createMentionComments(post, usersToMention);
        }
    }

    private List<User> getQueueUsers(String queueName) {
        Group queue = [SELECT Id FROM Group WHERE type='Queue' AND Name=:queueName LIMIT 1];
        List<User> users = new List<User>();
        for (GroupMember currentGroupMember:  [Select UserOrGroupId From GroupMember where GroupId =:queue.Id]) {
            if (isUser(currentGroupMember)){
                // TODO: Also add return of sub group users
                users.add(new User(Id = currentGroupMember.UserOrGroupId));
            }
        }
        return users;
    }

    private Boolean isUser(GroupMember userOrGroup) {
        // I have no idea why they have no Param indicating what this is :(
        return String.valueOf(userOrGroup.UserOrGroupId).startsWith('005');
    }

    private FeedItem createChatterPostForTrade(Trade__c trade) {
        FeedItem newPost = new FeedItem();
        newPost.ParentId = trade.Id;
        newPost.Body = System.Label.NewTradePost;
        newPost.Body = newPost.Body.replace('{sellCcy}', trade.SellCurrency__c);
        newPost.Body = newPost.Body.replace('{sellAmount}', String.valueOf(trade.SellAmount__c));
        newPost.Body = newPost.Body.replace('{buyCcy}', trade.BuyCurrency__c);
        newPost.Body = newPost.Body.replace('{buyAmount}', String.valueOf(trade.BuyAmount__c));
        newPost.Body = newPost.Body.replace('{rate}', String.valueOf(trade.Rate__c));
        newPost.Body = newPost.Body.replace('{date}',  string.valueOfGmt(trade.DateBooked__c));
        newPost.Body = newPost.Body.replace('{tradeLink}', URL.getSalesforceBaseUrl().toExternalForm() + 
            '/' + trade.Id);
        return newPost;
    }

    private void createMentionComments(FeedItem post, List<User> usersToMention) {
        // TODO: Add breakup in several comments so we may surpass 25 mentions limit
        if (usersToMention.isEmpty()) {
            // No need to create comments for 0 users
            return;
        }

        ConnectApi.CommentInput commentInput = new ConnectApi.CommentInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

        for (User user : usersToMention) {
            ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
            mentionSegmentInput.id = user.Id;
            messageBodyInput.messageSegments.add(mentionSegmentInput);
        }

        commentInput.body = messageBodyInput;
        ConnectApi.Comment commentRep = ConnectApi.ChatterFeeds.postCommentToFeedElement(null, post.Id, commentInput, null);
    }
}
