@IsTest
public class AccountHandlerTest {
    @IsTest
    static void testHandleAccounts() {
        // Create test data
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 10; i++) {
            accounts.add(new Account(Name = 'Test Account ' + i));
        }
        insert accounts;

        // Call the method being tested
        AccountHandler handler = new AccountHandler();
        handler.handleAccounts(accounts);

        // Verify the results
        for (Account acc : accounts) {
            System.assertEquals('123 Main St', acc.BillingStreet);
            System.assertEquals('San Francisco', acc.BillingCity);
            System.assertEquals('CA', acc.BillingState);
            System.assertEquals('94107', acc.BillingPostalCode);
            System.assertEquals('USA',acc.BillingCountry);
            
        }
    }
}