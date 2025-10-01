@isTest
public class AccountManagerTest {
    @isTest
    static void testCreateAccount() {
        // Arrange
        String accountName = 'Test Account';
        String accountNumber = '12345';
        String industry = 'Technology';

        // Act
        Test.startTest();
        AccountManager.createAccount(accountName, accountNumber, industry);
        Test.stopTest();

        // Assert
        Account createdAccount = [SELECT Id, Name, AccountNumber, Industry FROM Account WHERE Name = :accountName LIMIT 1];
        System.assertNotEquals(null, createdAccount, 'Account should be created');
        System.assertEquals(accountName, createdAccount.Name, 'Account name should match');
        System.assertEquals(accountNumber, createdAccount.AccountNumber, 'Account number should match');
        System.assertEquals(industry, createdAccount.Industry, 'Industry should match');
    }
}