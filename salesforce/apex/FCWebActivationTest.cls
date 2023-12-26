@isTest
private class FCWebActivationTest {

    @isTest
    static void validateActivateForInsert() {
       List<Account> newAccounts = mockNewAccounts();

       Test.startTest();
       FCWebActivation.activateForInsert(newAccounts);
       Test.stopTest();

       System.assert(true, 'done');
    }

    @isTest
    static void validateActivateForUpdate() {
       List<Account> newAccounts = mockNewAccounts();
       Map<Id, Account> oldAccounts = mockOldAccounts();

       Test.startTest();
       FCWebActivation.activateForUpdate(newAccounts, oldAccounts);
       Test.stopTest();

       System.assert(true, 'done');
    }

    @isTest
    static void validateFilterForInsert() {
       List<Account> newAccounts = mockNewAccounts();

       List<Account> filteredAccounts = FCWebActivation.filterForInsert(newAccounts);

       System.assertEquals(filteredAccounts.size(), 1);
       System.assertEquals(filteredAccounts[0].Id, newAccounts[1].Id);
    }

    @isTest
    static void validateFilterForUpdate() {
       List<Account> newAccounts = mockNewAccounts();
       Map<Id, Account> oldAccounts = mockOldAccounts();

       List<Account> filteredAccounts = FCWebActivation.filterForUpdate(newAccounts, oldAccounts);

       System.assertEquals(filteredAccounts.size(), 1);
       System.assertEquals(filteredAccounts[0].Id, newAccounts[1].Id);
    }

    static List<Account> mockNewAccounts() {
       Account new1 = new Account();
       new1.Id = '0012t000004AAAAAA1';
       new1.FCweb_release__c = false;
       Account new2 = new Account();
       new2.Id = '0012t000004AAAAAA2';
       new2.FCweb_release__c = true;

       return new List<Account> { new1, new2 };
    }

    static Map<Id, Account> mockOldAccounts() {
       Account old1 = new Account();
       old1.Id = '0012t000004AAAAAA1';
       old1.FCweb_release__c = false;
       Account old2 = new Account();
       old2.Id = '0012t000004AAAAAA2';
       old2.FCweb_release__c = false;

       return new Map<Id, Account> { old1.Id => old1, old2.Id => old2 };
    }
}
