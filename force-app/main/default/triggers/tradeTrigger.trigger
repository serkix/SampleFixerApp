trigger tradeTrigger on Trade__c (
    before insert, before update, before delete,
    after insert, after update, after delete
) {
    new TradeService().handleTrigger();
}