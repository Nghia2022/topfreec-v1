public class FCWebActivation {

    public static void activateForInsert(List<Account> newAccounts) {
      List<Account> accounts = filterForInsert(newAccounts);

      for (Account a: accounts) {
        String url = 'callout:FCWebActivationAPI/api/v1/fc_users/' + a.PersonContactId + '/activate';
        Map<String, String> body = new Map<String, String> { 'lead_no' => a.ConsulId_lead__c };

        FCWebCallout.callout(url, JSON.serialize(body));
      }
    }

    public static void activateForUpdate(List<Account> newAccounts, Map<Id, Account> oldAccounts) {
      List<Account> accounts = filterForUpdate(newAccounts, oldAccounts);

      for (Account a: accounts) {
        String url = 'callout:FCWebActivationAPI/api/v1/fc_users/' + a.PersonContactId + '/activate';
        Map<String, String> body = new Map<String, String> { 'lead_no' => a.ConsulId_lead__c };

        FCWebCallout.callout(url, JSON.serialize(body));
      }
    }

    public static List<Account> filterForInsert(List<Account> newAccounts) {
      List<Account> filteredAccounts = new List<Account>();

      for (Account newAccount :newAccounts) {
        if (newAccount.FCweb_release__c) {
          filteredAccounts.add(newAccount);
        }
      }

      return filteredAccounts;
    }

    public static List<Account> filterForUpdate(List<Account> newAccounts, Map<Id, Account> oldAccounts) {
      List<Account> filteredAccounts = new List<Account>();

      for (Account newAccount :newAccounts) {
        Account oldAccount = oldAccounts.get(newAccount.Id);

        Boolean newFlag = newAccount.FCweb_release__c;
        Boolean oldFlag = oldAccount.FCweb_release__c;

        if (!oldFlag && newFlag) {
          filteredAccounts.add(newAccount);
        }
      }

      return filteredAccounts;
    }


}
