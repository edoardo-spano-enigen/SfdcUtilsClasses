@isTest
private class TTest {

    @isTest
    static void testGetInstance() {
        T.getInstance();
    }

    @isTest
    private static void testFromFilter() {
        // Execute method
        T result = new T(new List<SObject>(), new Map<Id,SObject>());
        result = result.fromFilter(new List<Account>());

        // Asserts
        System.assertEquals(result.oldMap, new Map<Id, Account>(), 'OldMap should be a new Map');
    }

    @isTest
    private static void testFields() {
        T t = new T(new List<SObject>(), new Map<Id,SObject>());
        Map<String, Schema.SObjectField> fields = t.getFields();
        System.assertNotEquals(null, fields);
    }

    @isTest
    private static void testObjectName() {
        T t = new T(new List<SObject>(), new Map<Id,SObject>());
        System.assertEquals('Attachment', t.getObjectName());
    }

    @isTest
    private static void testInsert() {
        Account acct = new Account(Name='Test');
        insert acct;
        T t = new T(new List<SObject>(), new Map<Id,SObject>());
        System.assertEquals(true, t.isChanged(acct, 'Name'));
    }

    @isTest
    private static void testGetChanged() {
        // Query changed records
        AccountHistory[] changedRecordsStringField = [SELECT Id,Field,OldValue,NewValue FROM AccountHistory WHERE Field = 'Name'];
        AccountHistory[] changedRecordsBooleanField = [SELECT Id,Field,OldValue,NewValue FROM AccountHistory WHERE Field = 'IsDeleted'];
        AccountHistory[] changedRecordsReferenceField = [SELECT Id,Field,OldValue,NewValue FROM AccountHistory WHERE Field = 'AccountId'];

        // Test GetChanged method for String field
        SObject[] changedRecordsStringFieldResult = changedRecordsStringField;
        Assert.areEqual(5, changedRecordsStringFieldResult.size());

        // Test GetChanged method for Boolean field
        SObject[] changedRecordsBooleanFieldResult = changedRecordsBooleanField;
        Assert.areEqual(1, changedRecordsBooleanFieldResult.size());

        // Test GetChanged method for Reference field
        SObject[] changedRecordsReferenceFieldResult = changedRecordsReferenceField;
        Assert.areEqual(1, changedRecordsReferenceFieldResult.size());
    }

    @isTest
    private static void testGetChanged4() {
        // just a simple test to cover the no-op case in the parent class
        AccountHistory[] historyList = new AccountHistory[0];
        T t = new T(new List<SObject>(), new Map<Id,SObject>());
        System.assertEquals(historyList, t.getChanged('Name', false));
    }

    @isTest
    private static void testGetChanged3() {
        Account acct = new Account(Name='TestAccount');
        insert acct;

        SObject[] changes = new SObject[]{};

        System.assert(changes.size() == 2, 'Changes should contain 2 fields');
        System.assert(changes[0].get('Name') == 'TestAccount', 'Account name should match');
        System.assert(changes[1].get('Name') == 'CreatedDate', 'CreatedDate should be included');
    }

    @isTest
    private static void testGetChanged2() {
        // Create test data
        List<AccountHistory> ahList = new List<AccountHistory>();
        AccountHistory ah1 = new AccountHistory();
        ah1.Field = 'Type';
        ahList.add(ah1);
        insert ahList;

        // Test the method
        T t = new T(new List<SObject>(), new Map<Id,SObject>());
        List<String> fieldList = new List<String>{'Type'};
        List<SObject> changedList = t.getChanged(fieldList, false);

        // Assert the results
        System.assertEquals(1, changedList.size());
    }

    @isTest
    private static void testGetChangedWithOldValue() {
        // Setup
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        acc.Name = 'Updated Name';
        update acc;

        // Execute
        T t = new T(new List<SObject>(), new Map<Id,SObject>());
        SObject[] changedRecords = t.getChangedWithOldValue('Name', 'Updated Name');

        // Assert
        System.assertEquals(1, changedRecords.size(), 'Unexpected number of records');
        Account updatedAccount = (Account)changedRecords[0];
        System.assertEquals('Updated Name', updatedAccount.Name, 'Name should be updated');
        System.assertEquals('Updated Name', updatedAccount.get('OldValue__c'), 'OldValue__c should match updated value');
        System.assertEquals('Test Account', updatedAccount.get('NewValue__c'), 'NewValue__c should match old value');
    }

    @isTest
    private static void testGetChangedWithOldValue2() {
        Account acc = new Account(Name = 'Test');
        insert acc;

        acc.Name = 'Test New';

        Test.startTest();
        update acc;
        Test.stopTest();

        List<AccountHistory> history = [SELECT Id, Field, OldValue, NewValue FROM AccountHistory WHERE AccountId = :acc.Id AND Field = 'Name'];

        System.assertEquals(1, history.size());
        System.assertEquals('Test', history[0].OldValue);
        System.assertEquals('Test New', history[0].NewValue);

        T t = new T(new List<SObject>(), new Map<Id,SObject>());
        SObject[] changedRecords = t.getChangedWithOldValue('Name', 'Test', false);
        System.assertEquals(1, changedRecords.size());
        System.assertEquals(history[0].Id, changedRecords[0].Id);
    }

    @isTest
    static void testGetOldValue() {
        Account acct = new Account(Name = 'Test Account');
        insert acct;

        T.TMode mode = T.TMode.xUPDATE;
        Map<Id, Account> oldMap = new Map<Id, Account>();
        oldMap.put(acct.Id, acct);

        Test.startTest();
        T t = new T(new List<SObject>(), new Map<Id,SObject>());
        System.assertEquals(acct.Name, t.getOldValue(acct, 'Name'));
        Test.stopTest();
    }

    @isTest
    private static void testFilterStringNotEqual() {
        List<PricebookEntry> records = new List<PricebookEntry>{
            new PricebookEntry(Id = '{SECRET_PLACEHOLDER}', Product2Id = '{SECRET_PLACEHOLDER}', UnitPrice = 100, IsActive = true),
            new PricebookEntry(Id = '{SECRET_PLACEHOLDER}', Product2Id = '{SECRET_PLACEHOLDER}', UnitPrice = 200, IsActive = true)
        };

        Test.startTest();
        T t = new T(new List<SObject>(), new Map<Id,SObject>());
        T filteredRecords = t.filter('Product2Id', records[0], false);
        Test.stopTest();

        System.assertEquals(null, filteredRecords, 'Unexpected number of filtered records');
    }

    @isTest
    private static void testFilter() {
        SObject[] triggerNew = new SObject[]{
            new Account(Name = 'Included', Industry = 'Technology'),
            new Account(Name = 'Excluded', Industry = 'Finance'),
            new Account(Name = 'Included again', Industry = 'Technology')
        };

        Map<Id, SObject> oldMap = new Map<Id, SObject>();
        for (SObject record : triggerNew) {
            oldMap.put(record.Id, record.clone(true, true, true, true));
        }

        T t = new T(new List<SObject>(), new Map<Id,SObject>());

        test.startTest();
        T filteredTriggerNew = t.filter('Industry', 'Technology', true);
        test.stopTest();

        System.assertEquals(null, filteredTriggerNew);
    }

    public T filterByOld(String field, Object value) {
        T t = new T(new List<SObject>(), new Map<Id,SObject>());
        return t.filterByOld(field, value, true);
    }

    @isTest
    static void testFilterByOld() {
        T.TMode mode = T.TMode.xINSERT;
        Map<Id, SObject> oldMap = new Map<Id, SObject>([select Id, Name, Industry from Account where Industry = 'Finance' limit 1]);
        SObject[] triggerNew = oldMap.values();

        T t = new T(new List<SObject>(), new Map<Id,SObject>());

        // Test 1: mode != TMode.xUPDATE
        System.assertEquals(1, t.filterByOld('Name', 'Test Account1', false).triggerNew.size());

        // Test 2: mode != TMode.xUPDATE || !getFields().containsKey(field)
        System.assertEquals(triggerNew.size(), t.filterByOld('NonExistentField', 'NonExistentValue', false).triggerNew.size());

        // Test 3: value != null
        System.assertEquals(0, t.filterByOld('Name', null, true).triggerNew.size());

        // Test 4: U.filter()
        System.assertEquals(1, t.filterByOld('Name', 'Finance', true).triggerNew.size());
    }

    @isTest
    private static void testIsAfterUpdate_False() {
        Test.startTest();
        Boolean result = T.isAfterUpdate();
        Test.stopTest();
        System.assertEquals(false, result, 'isAfterUpdate should be false when Trigger.isAfter is false');
    }

    @isTest
    static void testIsBeforeUpdate() {
        Test.startTest();
        Boolean isBeforeUpdate = T.isBeforeUpdate();
        Test.stopTest();
        System.assert(isBeforeUpdate, 'isBeforeUpdate should be true');
    }

    @isTest
    private static void testIsBeforeInsert() {
        Boolean isBeforeInsert = T.isBeforeInsert();
        System.assertEquals(true, isBeforeInsert, 'isBeforeInsert should be true');
    }

    @isTest
    private static void testIsAfterInsertFalse() {
        Boolean isAfterInsert = T.isAfterInsert();
        System.assertEquals(false, isAfterInsert, 'Unexpected isAfterInsert value');
    }

    @isTest
    private static void testIsBeforeDeleteFalse() {
        Boolean returnValue = false;
        Test.startTest();
        returnValue = T.isBeforeDelete();
        Test.stopTest();
        System.assertEquals(false, returnValue, 'isBeforeDelete should return false');
    }

    @isTest
    private static void testIsAfterDeleteAttachment(){
        System.assertEquals(true, T.isAfterDelete());
    }

    @isTest
    private static void testTrigger() {
        List<Attachment> attachments = new List<Attachment>();
        for (Integer i = 0; i < 5; i++) {
            Attachment attachment = new Attachment(
                ParentId = null,
                Name = 'Test Attachment',
                Body = Blob.valueOf('Test Body')
            );
            attachments.add(attachment);
        }
        insert attachments;
        
        List<Note> notes = new List<Note>();
        for (Integer i = 0; i < 5; i++) {
            Note note = new Note(
                ParentId = null,
                Title = 'Test Note',
                Body = 'Test Body'
            );
            notes.add(note);
        }
        insert notes;
        
        Test.startTest();
        delete attachments;
        delete notes;
        Test.stopTest();

        System.assert(T.isAfterUndelete(), 'isAfterUndelete should be true');
    }

}