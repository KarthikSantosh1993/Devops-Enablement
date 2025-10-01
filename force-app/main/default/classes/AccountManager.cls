public class AccountManager {
    public static void createAccount(String name, String accountNumber, String industry) {
        Account newAccount = new Account();
        newAccount.Name = name;
        newAccount.AccountNumber = accountNumber;
        newAccount.Industry = industry;

        try {
            insert newAccount;
        } catch (DmlException e) {
            System.debug('Error creating account: ' + e.getMessage());
        }
    }
}