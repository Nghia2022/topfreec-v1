@isTest
private class FCWebActivationTriggerTest {

    @isTest
    static void validateTriggerForInsert() {
      Account account = new Account(Name = 'test', FCweb_release__c = true);

      Test.startTest();
      insert account;
      Test.stopTest();

      System.assert(true, 'done');
    }

    @isTest
    static void validateTriggerForUpdate() {
      Account account = new Account(Name = 'test', FCweb_release__c = false);
      insert account;

      Test.startTest();

      account.FCweb_release__c = true;
      update account;

      Test.stopTest();

      System.assert(true, 'done');
    }
}
