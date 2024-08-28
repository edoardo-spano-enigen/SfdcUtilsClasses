@isTest
private class UTest {

    @isTest
    private static void testGetGlobalDescribe()
    {
        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectType> globalDescribeCache = new Map<String, Schema.SObjectType>();

        Test.startTest();
        globalDescribeCache = U.getGlobalDescribe();
        Test.stopTest();

        System.assertEquals(globalDescribe, globalDescribeCache, 'globalDescribeCache and globalDescribe should match');
    }

    @isTest
    private static void testGetSObjectValue()
    {
        // Create a dummy account
        Account a = new Account (
            Name = 'Test'
        );
        insert a;

        // Test single-level field
        Object name = U.getSObjectValue(a, 'Name');
        System.assertEquals('Test', name, 'Should get exact value');

        // Test invalid field
        Object invalidValue = U.getSObjectValue(a, 'Invalid');
        System.assertEquals(null, invalidValue, 'Should get null value for invalid field');

        // Test relationship field
        Contact c = new Contact (
            LastName    = 'TestContact',
            Account     = a
        );
        insert c;

        Object accName = U.getSObjectValue(c, 'Account.Name');
        System.assertEquals('Test', accName, 'Should get related value');
    }
    
    @isTest
    private static void testGetIdSet()
    {
        // Create test data
        List<Account> accs = new List<Account>();
        accs.add(new Account( Name = 'test 1' ));
        accs.add(new Account( Name = 'test 2' ));
        insert accs;

        Set<Id> ids;

        // Test method with Id field
        ids = U.getIdSet(accs, 'Id');
        System.assertEquals(2, ids.size(), 'expected 2 Ids in the result set');

        // Test method with a non-existing field
        ids = U.getIdSet(accs, 'NonExistentField');
        System.assertEquals(0, ids.size(), 'expected 0 Ids in the result set');
    }

    @isTest
    private static void testGetSet()
    {
        // Create test data
        List<Account> accs = new List<Account>();
        accs.add(new Account( Name = 'test 1' ));
        accs.add(new Account( Name = 'test 2' ));
        insert accs;

        Set<String> stringSet;

        // Test method with Name field
        stringSet = U.getSet(accs, 'Name');
        System.assertEquals(2, stringSet.size(), 'expected 2 strings in the result set');

        // Test method with a non-existing field
        stringSet = U.getSet(accs, 'NonExistentField');
        System.assertEquals(0, stringSet.size(), 'expected 0 strings in the result set');
    }

    @isTest
    private static void testKeyBy()
    {
        // Create test data
        List<Account> accs = new List<Account>();
        accs.add(new Account( Name = 'Account1' ));
        accs.add(new Account( Name = 'Account2' ));
        accs.add(new Account( Name = 'Account3' ));
        insert accs;

        // Test the keyBy method with the Id field
        Map<String, SObject> idMap = U.keyBy(accs, 'Id');
        System.assertEquals(3, idMap.size(), 'The map should have 3 values');

        // Test the keyBy method with the Name field
        Map<String, SObject> nameMap = U.keyBy(accs, 'Name');
        System.assertEquals(3, nameMap.size(), 'The map should have 3 values');

        // Test the keyBy method with a field that doesn't exist
        Map<String, SObject> nonExistentFieldMap = U.keyBy(accs, 'NonExistentField');
        System.assertEquals(0, nonExistentFieldMap.size(), 'The map should be empty');
    }

    @isTest
    private static void testKeyByRegex()
    {
        // Create test data
        List<Account> accs = new List<Account>();
        accs.add(new Account( Name = 'Account1', AccountNumber = '1111' ));
        accs.add(new Account( Name = 'Account2', AccountNumber = '2222' ));
        accs.add(new Account( Name = 'Account3', AccountNumber = '3333' ));
        insert accs;

        // Test the keyBy method with the concatenation of Name and AccountNumber fields
        Map<String, SObject> idMap = U.keyBy(accs, '{Name}_{AccountNumber}', true);
        System.assertEquals(3, idMap.size(), 'The map should have 3 values');
    }

    @isTest
    private static void testKeyByRegexWithNulls()
    {
        // Create test data
        List<Account> accs = new List<Account>();
        accs.add(new Account( Name = 'Account1', AccountNumber = '1111' ));
        accs.add(new Account( Name = 'Account2', AccountNumber = null ));
        accs.add(new Account( Name = 'Account3', AccountNumber = '3333' ));
        insert accs;

        // Test the keyBy method with the concatenation of Name and AccountNumber fields
        Map<String, SObject> idMap = U.keyBy(accs, '{Name}_{AccountNumber}', true, true);
        System.assertEquals(3, idMap.size(), 'The map should have 3 values');
    }

    @isTest
    private static void testGroupBy()
    {
        // Create test data
        List<Account> accs = new List<Account>();
        accs.add(new Account( Name = 'Account1' ));
        accs.add(new Account( Name = 'Account2' ));
        accs.add(new Account( Name = 'Account3' ));
        insert accs;

        Map<String, SObject[]> mapByName = U.groupBy(accs, 'Name');

        System.assertEquals(3, mapByName.size(), 'The map should have 3 entries');
        System.assertEquals(1, mapByName.get('Account1').size(), 'Account1 should be in the map');
        System.assertEquals(1, mapByName.get('Account2').size(), 'Account2 should be in the map');
        System.assertEquals(1, mapByName.get('Account3').size(), 'Account3 should be in the map');
    }

    @isTest
    private static void testGroupByPattern()
    {
        // Create test data
        List<Account> accs = new List<Account>();
        accs.add(new Account( Name = 'Account1' ));
        accs.add(new Account( Name = 'Account2' ));
        accs.add(new Account( Name = 'Account3' ));
        insert accs;

        Map<String, SObject[]> mapByName = U.groupBy(accs, '{Name}', true);

        System.assertEquals(3, mapByName.size(), 'The map should have 3 entries');
        System.assertEquals(1, mapByName.get('Account1').size(), 'Account1 should be in the map');
        System.assertEquals(1, mapByName.get('Account2').size(), 'Account2 should be in the map');
        System.assertEquals(1, mapByName.get('Account3').size(), 'Account3 should be in the map');
    }

    @isTest
    private static void testGroupByRegex()
    {
        // Create test data
        List<Account> accs = new List<Account>();
        accs.add(new Account( Name = 'Account1' ));
        accs.add(new Account( Name = 'Account2' ));
        accs.add(new Account( Name = 'Account3' ));
        insert accs;

        Map<String, SObject[]> mapByName = U.groupByRegex(accs, '{Name}');

        System.assertEquals(3, mapByName.size(), 'The map should have 3 entries');
        System.assertEquals(1, mapByName.get('Account1').size(), 'Account1 should be in the map');
        System.assertEquals(1, mapByName.get('Account2').size(), 'Account2 should be in the map');
        System.assertEquals(1, mapByName.get('Account3').size(), 'Account3 should be in the map');
    }

    @isTest
    private static void testAddToGMap()
    {
        Map<String, List<SObject>> m = new Map<String, List<SObject>>();

        Account a1 = new Account( Name = 'Test1', Industry = 'Technology' );
        Account a2 = new Account( Name = 'Test2', Industry = 'Finance' );

        U.addToGMap(m, 'Industry', a1);
        U.addToGMap(m, 'Industry', a2);

        System.assertEquals(1, m.size(), 'The map should have 1 entry');
        System.assertEquals(2, m.get('Industry').size(), 'The map should have 2 entries in the Industry group');
        System.assertEquals(a1, m.get('Industry')[0], 'The first element of the list in Industry group is not correct');
    }

    @isTest
    private static void testReverse()
    {
        List<Object> objList = new List<Object>{'a', 'b', 'c', 'd'};
        List<Object> expected = new List<Object>{'d', 'c', 'b', 'a'};
        List<Object> actual = (List<Object>)U.reverse(objList);
        System.assertEquals(expected, actual, 'The reverse of the list is not correct');
    }

    @isTest
    private static void testFilter()
    {
        // Create test data
        List<Account> accs = new List<Account>();
        accs.add(new Account( Name = 'Account1', AccountNumber = '1111' ));
        accs.add(new Account( Name = 'Account2', AccountNumber = '2222' ));
        accs.add(new Account( Name = 'Account3', AccountNumber = '3333' ));
        insert accs;

        // Filter with a valid value
        List<Account> expected = new List<Account>{accs[0]};
        List<Account> actual = (List<Account>)U.filter(accs, 'Name', 'Account1');
        System.assertEquals(expected, actual, 'The filter is not correct');

        // Filter with an invalid value
        expected = new List<Account>();
        actual = (List<Account>)U.filter(accs, 'Name', 'Account4');
        System.assertEquals(expected, actual, 'The filter is not correct');
    }
    
    @isTest
    private static void testFilterIncludeOrExclude() {
        // Create test data
        List<Account> accs = new List<Account>();
        accs.add(new Account( Name = 'Account1', AccountNumber = '1111' ));
        accs.add(new Account( Name = 'Account2', AccountNumber = '2222' ));
        accs.add(new Account( Name = 'Account3', AccountNumber = '3333' ));
        insert accs;

        // Filter with a valid value
        List<Account> expected = new List<Account>{accs[1], accs[2]};
        List<Account> actual = (List<Account>)U.filter(accs, 'Name', 'Account1', false);
        System.assertEquals(expected, actual, 'The filter is not correct');

        // Filter with an invalid value
        expected = new List<Account>{accs[0], accs[1], accs[2]};
        actual = (List<Account>)U.filter(accs, 'Name', 'Account4', false);
        System.assertEquals(expected, actual, 'The filter is not correct');
    }

    @isTest
    private static void testFilterListValue() {
        // Assuming there's a PricebookEntry object in the org, get its ID
        Id pbId = [SELECT Id FROM Pricebook2 WHERE isStandard = true LIMIT 1].Id;

        // Create a few PricebookEntry records for testing
        List<PricebookEntry> testEntries = new List<PricebookEntry>();
        for (Integer i = 1; i <= 3; i++) {
            testEntries.add(new PricebookEntry(
                Pricebook2Id = pbId,
                Product2Id = '{SECRET_PLACEHOLDER}',  // Replace with the actual Product2 Id of your org
                UnitPrice = 100 * i,
                IsActive = true
            ));
        }
        insert testEntries;

        // Test the U.filter method
        Set<String> valueSet = new Set<String>{ '100', '200', '300' };
        List<PricebookEntry> filteredEntries = (List<PricebookEntry>) U.filter(testEntries, 'UnitPrice', valueSet);

        // Assert that the filtered entries have UnitPrices within the given valueSet
        for (PricebookEntry entry : filteredEntries) {
            System.assert(valueSet.contains(entry.UnitPrice.toString()));
        }
    }

    @isTest
    private static void testFilterString() {
        PricebookEntry pb = [select id, Product2Id from pricebookentry limit 1];
        SObject[] filtered = U.filter([select id, Product2Id from pricebookentry], 'Product2Id', new Set<String>{pb.Product2Id}, true);
        System.assertEquals(1, filtered.size());
    }

    @isTest
    public static void testGetProfiles() {
        test.startTest();
        Map<String, SObject> profiles = U.getProfiles();
        test.stopTest();
        
        System.assertEquals(1, profiles.size());
        Profile p = (Profile)profiles.values()[0];
        System.assertEquals('System Administrator', p.Name);
    }

    @isTest
    private static void testGetRecordTypes() {
        Map<String, SObject> rts1 = U.getRecordTypes('Account');
        Map<String, SObject> rts2 = U.getRecordTypes('Account');
        System.assertEquals(rts1.size(), rts2.size());

        Map<String, Schema.RecordTypeInfo> accountRTs = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
        for (String key : rts1.keySet()) {
        SObject rtSObj = rts1.get(key);
        Id rtId = (Id) rtSObj.get('Id');
        Schema.RecordTypeInfo rtInfo = accountRTs.get(key);
        System.assertEquals(rtId, rtInfo.getRecordTypeId());
        }
    }

    @isTest
    public static void testGetRtMap() {
        Map<String, Id> rtMap = U.getRtMap('Account');

        System.assertNotEquals(0, rtMap.size());
        //Account RT can change over time via schema customizations, so we don't hardcode the value here.
    }

    @isTest
    private static void testToSet() {
        List<String> l = new List<String>();
        l.add('a');
        l.add('b');
        l.add('c');
        System.assertEquals(new Set<String>{'a','b','c'}, U.toSet(l), 'testToSet');
    }

    @isTest
    private static void testToList() {

        List<String> strList = new List<String>{'a', 'b'};
        Set<String> strSet = new Set<String>(strList);

        List<String> result = U.toList(strSet);

        System.assertEquals(strList, result);
    }

    @isTest
    private static void testToIdList() {
        List<Id> idList;

        Test.startTest();
        idList = U.toIdList(new Set<Id>{});
        Test.stopTest();

        System.assertEquals(0, idList.size(), 'Empty set should produce an empty list');

        idList = null;

        Test.startTest();
        idList = U.toIdList(new Set<Id>{'{SECRET_PLACEHOLDER}', '{SECRET_PLACEHOLDER}'});
        Test.stopTest();

        System.assertEquals(2, idList.size(), 'Set should contain 2 IDs');
    }

    @isTest
    public static void testMassSet() {
        Account a = new Account(Name = 'Test');
        Account b = new Account();
        SObject[] objs = new SObject[] {a, b};
        
        U.massSet(objs, 'Name', 'Test Account');
        
        System.assertEquals('Test Account', a.get('Name'));
        System.assertEquals('Test Account', b.get('Name'));
    }

    @isTest
    private static void testGetPicklistMap() {
        Schema.DescribeFieldResult fieldResult = Account.Type.getDescribe();
        Map<String, String> picklistMap = U.getPicklistMap(fieldResult);
        System.assertNotEquals(null, picklistMap, 'Picklist map should not be null');
    }

    @isTest
    private static void testGetPicklistMapField() {
        Map<String, String> picklistMap = U.getPicklistMap(Account.Type);
        System.assertNotEquals(null, picklistMap);
        // Add additional assertions to verify the picklist mapping
        System.assertEquals(7, picklistMap.size());
    }

    @isTest
    public static void testGetUserIPAddress() {
        boolean success;
        // String ipAddress = '';
        // Map<String, String> myMap = Auth.SessionManagement.getCurrentSession();
        // ipAddress = myMap.get('SourceIp');

        // System.assertEquals(ipAddress, '255.255.255.255');
        // System.assertEquals(true, false);

        try {
            String ipAddress = U.getUserIPAddress();
            System.assertEquals(ipAddress, '255.255.255.255');
            success = true;
        } catch (Exception e) {
            System.assert(false, 'Unexpected exception was thrown: ' + e.getMessage());
        }

        System.assertEquals(success, true);
    }

    @isTest
    private static void testSetIfEmpty() {
        Account a = new Account();
        U.setIfEmpty(a, 'Name', 'Test Account');
        System.assertEquals('Test Account', a.Name);

        a.Name = 'Test Account 1';
        U.setIfEmpty(a, 'Description', 'Test Description');
        System.assertEquals('Test Description', a.Description);
    }

    @isTest
    private static void testIsAsync() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Test.startTest();
            // Test the isAsync method
            Assert.areEqual(true, U.isAsync(), 'Unexpected result');
            Test.stopTest();
        }
    }

    @isTest
    private static void testSubstring() {
        System.assertEquals('abc', U.substring('abcde', 0, 3));
        System.assertEquals('def', U.substring('abcde', 3, 6));
        System.assertEquals('', U.substring('abcde', 4, 2));
        System.assertEquals('', U.substring('abcde', 6, 4));
        System.assertEquals('', U.substring('abcde', 6, 6));
        System.assertEquals('', U.substring('abcde', 7, 1));
        System.assertEquals('', U.substring('abcde', 7, 0));
        System.assertEquals('', U.substring('abcde', -1, 2));
        System.assertEquals('abc', U.substring('abc', 0, 3));
        System.assertEquals('', U.substring('abc', 0, -1));
        System.assertEquals('', U.substring('abc', 3, 3));
        System.assertEquals('', U.substring('abc', 3, -1));
        System.assertEquals('', U.substring('abc', 4, 0));
        System.assertEquals('', U.substring('', 0, 1));
        System.assertEquals('', U.substring('', 1, 0));
        System.assertEquals('', U.substring('', -1, 0));
        System.assertEquals('', U.substring('', -1, -1));
        System.assertEquals('a', U.substring('a', 0, 0));
        System.assertEquals('', U.substring('a', 0, -1));
        System.assertEquals('', U.substring('a', -1, 0));
        System.assertEquals('', U.substring('a', -1, -1));
    }

    @isTest
    private static void testGetFieldsDescribeForSObject() {
        Test.startTest();
        Map<String, Schema.SObjectField>  fieldsDescribeForSObject = U.getFieldsDescribeForSObject('Account');
        Test.stopTest();
        System.assertNotEquals(0, fieldsDescribeForSObject.size(), 'No fields found for Account');
    }

    @isTest
    private static void testGetCreatableFieldsNamesForSObject() {
        // Get the describe result for the Account object
        Schema.DescribeSObjectResult describeResult = Schema.sObjectType.Account;

        // Get all the fields of the Account object
        List<Schema.SObjectField> fields = describeResult.fields.getMap().values();

        // Create a set to store the API names of the fields of the Account object
        Set<String> fieldAPINames = new Set<String>();

        // Iterate through the fields and check if the field is creatable
        for (Schema.SObjectField field : fields) {
            if (field.getDescribe().isCreateable()) {
                // If the field is creatable, add it to the set
                fieldAPINames.add(field.getDescribe().getName());
            }
        }

        Test.startTest();
        // Call the method that returns the creatable field API names for the Account object
        List<String> creatableFieldNames = U.getCreatableFieldsNamesForSObject('Account');

        // Assert that the returned list contains the same API names of creatable fields for the Account object
        System.assertEquals(fieldAPINames, new Set<String>(creatableFieldNames));
        Test.stopTest();
    }

    @isTest
    private static void testOptional() {
        List<Account> retList = U.optional(new List<Account>{new Account(Name='TestAccount')});
        List<Account> retListEmpty = U.optional(null);
        
        System.assertEquals(1, retList.size());
        
        System.assertEquals(0, retListEmpty.size());
    }

    @isTest
    private static void testJoin() {
        List<Account> accList = new List<Account>();
        List<Contact> conList = new List<Contact>();
        Account acc = new Account(Name = 'TestAcc');
        insert acc;
        for(Integer i = 0; i < 5; i++) {
            conList.add(new Contact(LastName = 'TestCon'+i, AccountId = acc.Id));
        }
        Test.startTest();
        U.join(accList, conList);
        Test.stopTest();
        System.assertEquals(1, accList.size(), 'accList size should be 1');
        System.assertEquals(5, conList.size(), 'conList size should be 5');
    }

    @isTest
    private static void testJoinSetString() {
        Set<String> firstSet = new Set<String>{'John', 'Jane', 'Bob'};
        Set<String> secondSet = new Set<String>{'Sarah', 'Mary', 'Mary'};
        Test.startTest();
        Set<String> result = U.join(firstSet, secondSet);
        Test.stopTest();
        System.assertEquals(result, new Set<String>{'John', 'Jane', 'Bob', 'Sarah', 'Mary'}, 'Join Set String Test');
    }

    @isTest
    static void testSplit() {
        String[] v = U.split('','');
        System.assertEquals(0, v.size());
        
        v = U.split('a','a');
        System.assertEquals(1, v.size());
        
        v = U.split('a.b','.');
        System.assertEquals(2, v.size());
    }

    @isTest
    private static void testSplitAndTrimToList() {
        // Test data
        String inputString = '  Hello  ,  World  ,  Salesforce  ';

        // Call the method to be tested
        List<String> result = U.splitAndTrimToList(inputString, ',');

        // Assert the results
        System.assertEquals(3, result.size());
        System.assertEquals('Hello', result[0]);
        System.assertEquals('World', result[1]);
        System.assertEquals('Salesforce', result[2]);
    }

    @isTest
    private static void testChunks() {
        String longString = 'Long string that requires chunking.';
        List<String> chunks = U.chunks(longString, 10);
        Assert.areEqual(3, chunks.size(), 'Incorrect number of chunks.');
        Assert.areEqual('Long strin', chunks[0], 'First chunk does not start with expected string.');
        Assert.areEqual('g that req', chunks[1], 'Second chunk does not start with expected string.');
        Assert.areEqual('uires.', chunks[2], 'Third chunk does not start with expected string.');
    }

    @isTest
    static void testAddToMultiselect() {
        String multiselect = 'test1;test3';
        String addedValue = 'test2;test4';
        String result = U.addToMultiselect(multiselect, addedValue);
        System.assertEquals('test1;test2;test3;test4', result);
    }

    @isTest
    static void testReplaceInMultiselect() {
        Note n = new Note(Title = 'Test', Body = 'Value1;Value2;Value3');
        insert n;
        String newMultiSelectValue = U.replaceInMultiselect('Value1;Value3', 'Value1', 'Value4');
        System.assertEquals('Value4;Value2;Value3', newMultiSelectValue);
    }

    @isTest
    private static void testDoPartition() {
        List<Object> totalList = new List<Object>{'A', 'B', 1, 'C', 'D', 2, 'B'};

        Type t = Type.forName('U');
        List<List<Object>> result = (List<List<Object>>)t.newInstance();

        Test.startTest();
        result = U.doPartition(totalList, 3, t);
        Test.stopTest();

        System.assertEquals(3, result.size());
        Set<Object> expectedSet = new Set<Object>{'A', 'C', 'D', 2, 'B'};
        for(Integer i=0; i<result.size(); i++){
            List<Object> row = result.get(i);
            for(Object col : row){
                System.assert(!expectedSet.contains(col), 'Unexpected data in ' + i + ',' + col);
                expectedSet.remove(col);
            }
        }
    }

    @isTest
    private static void testGetRecordTypeId() {
        String accountRecTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Industries' LIMIT 1].Id;

        Test.startTest();
        String recTypeId = U.getRecordTypeId('Account', 'Industries');
        Test.stopTest();

        System.assertEquals(accountRecTypeId, recTypeId, 'Record Type IDs should match');
    }

    @isTest
    private static void testFilterListNullOr() {
        List<Lead> leads = new List<Lead>{
            new Lead(FirstName = 'John', LastName = 'Doe'),
            new Lead(FirstName = 'Jane', LastName = 'Smith'),
            new Lead(FirstName = null, LastName = null),
            new Lead(FirstName = 'Bob', LastName = 'Johnson')
        };

        List<Lead> filteredList = U.filterListNullOr(leads, new String[]{'FirstName', 'LastName'});
        System.assertEquals(3, filteredList.size());
    }

    @isTest
    private static void testGetSaveResultStringError() {
        Database.SaveResult sr = (Database.SaveResult)JSON.deserialize('{"success":false,"errors":[{"message":"This account can not be inserted", "statusCode":"FIELD_CUSTOM_VALIDATION_EXCEPTION"}]}',
                                                                                Database.SaveResult.class);

        // Call U.getSaveResultStringError() method
        String errorMessage = U.getSaveResultStringError(sr);

        // Assertion
        System.assertEquals('This account can not be inserted', errorMessage, 'Error message should match');
    }

    @isTest
    private static void testIsBatchRunning() {
        // Check if batch is running
        Boolean isBatchRunning = U.isBatchRunning('UselessBatchClass');

        // Assert that batch is running
        System.assertEquals(false, isBatchRunning, 'Batch should not be running');
    }

    @isTest
    private static void testIsBatchRunningList() {
        Set<String> batchNameSet = new Set<String>{'BatchableA', 'BatchableB'};

        // isBatchRunning should return false when no batch is running
        Boolean ret = U.isBatchRunning(batchNameSet);
        System.assertEquals(false, ret, 'testIsBatchRunning false');

        // isBatchRunning should return true when at least one batch is running
        Test.startTest();
        ret = U.isBatchRunning(batchNameSet);
        Test.stopTest();
        System.assertEquals(true, ret, 'testIsBatchRunning true');
    }

}