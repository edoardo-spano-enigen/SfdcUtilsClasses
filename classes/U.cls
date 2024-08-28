/**
 * @description: General utility class. Here you can find the most common functions that you could need in your implementation.
 * @TestClass: UTest
 */
public class U
{

    /**
     * @description  Method that returns the schema global describe
     * @return       String with concatenated records ID
     */
    private static Map<String, Schema.SObjectType> globalDescribeCache = new Map<String, Schema.SObjectType>();
    public static Map<String, Schema.SObjectType> getGlobalDescribe()
    {
        System.debug('# U.getGlobalDescribe # START');
        System.debug('# U.getGlobalDescribe # globalDescribeCache.size(): ' + globalDescribeCache.size());

        // If the globalDescribeCache is empty, we fill it up with the global describe information
        if(globalDescribeCache.size() == 0)
        {
            Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();

            System.debug('# U.getGlobalDescribe # globalDescribe.size(): ' + globalDescribe.size());

            for(String key : globalDescribe.keySet())
            {
                System.debug('# U.getGlobalDescribe # key: ' + key);
                System.debug('# U.getGlobalDescribe # SObjectType: ' + globalDescribe.get(key));
                
                globalDescribeCache.put(key, globalDescribe.get(key));
            }

            System.debug('# U.getGlobalDescribe # globalDescribeCache.size(): ' + globalDescribeCache.size());
        }

        System.debug('# U.getGlobalDescribe # END');

        return globalDescribeCache;
    }

    /**
     * @description  Method that returns the value of the given SObject's field
     * @param        obj: SObject from which get the value
     * @param        field: API name of the field
     * @return       Object with the value of the field
     */
    public static Object getSObjectValue(SObject obj, String field)
    {
        System.debug('# U.getSObjectValue # START');
        System.debug('# U.getSObjectValue # obj: ' + obj);
        System.debug('# U.getSObjectValue # field: ' + field);

        // Return null if the SObject is null or the field API name is empty
        if(String.isBlank(field) || obj == null)
        {
            System.debug('# U.getSObjectValue # obj is null or field is empty');
            System.debug('# U.getSObjectValue # END');
            
            return null;
        }
        // Else the sub-method getSObjectValueWithoutChecks is called to retrieve the field value
        else
        {
            System.debug('# U.getSObjectValue # obj is not null and field is not empty');
            
            return getSObjectValueWithoutChecks(obj, field, !field.contains('.'));
        }
    }

    /**
     * @description  Method that returns the value of the given SObject's field
     * @param        obj: SObject from which get the value
     * @param        field: API name of the field
     * @param        isPlainField: True if the field is at core object level
     * @return       Object with the value of the field
     */
    private static Map<String, String[]> tokensMap = new Map<String, String[]>();
    private static Object getSObjectValueWithoutChecks(SObject obj, String field, Boolean isPlainField)
    {
        System.debug('# U.getSObjectValueWithoutChecks # START');
        System.debug('# U.getSObjectValueWithoutChecks # obj: ' + obj);
        System.debug('# U.getSObjectValueWithoutChecks # field: ' + field);
        System.debug('# U.getSObjectValueWithoutChecks # isPlainField: ' + isPlainField);
        System.debug('# U.getSObjectValueWithoutChecks # tokensMap: ' + tokensMap);

        try
        {
            // If it is a plain field, the value is retrieved from the core object
            if(isPlainField)
            {
                System.debug('# U.getSObjectValueWithoutChecks # obj.get(field): ' + obj.get(field));
                System.debug('# U.getSObjectValueWithoutChecks # END');

                return obj.get(field);
            }
            // Else the field is a reference field
            else
            {
                SObject subObj = obj;
                if(!tokensMap.containsKey(field))
                {
                    tokensMap.put(field, field.split('\\.'));
                }
                List<String> tokens = tokensMap.get(field);
                for(Integer i = 0; i < tokens.size() - 1; i++)
                {
                    subObj = subObj.getSObject(tokens[i]);
                }

                System.debug('# U.getSObjectValueWithoutChecks # subObj: ' + subObj);
                System.debug('# U.getSObjectValueWithoutChecks # return: ' + subObj.get(tokens[tokens.size() - 1]));
                System.debug('# U.getSObjectValueWithoutChecks # END');

                return subObj.get(tokens[tokens.size() - 1]);
            }
        }
        catch(Exception e)
        {
            System.debug('# U.getSObjectValueWithoutChecks # ERROR: ' + e.getMessage());
            System.debug('# U.getSObjectValueWithoutChecks # END');
            return null;
        }
    }

    /**
     * @description  Method that extracts a set of ids from a list of objects
     * @param        objList: List of SObject from which get the ids
     * @param        idField: API name of the id field
     * @return       Set of ids from list of objects
     */
    public static Set<Id> getIdSet(List<SObject> objList, String idField)
    {
        System.debug('# U.getIdSet # START');
        System.debug('# U.getIdSet # objList: ' + objList);
        System.debug('# U.getIdSet # idField: ' + idField);

        Set<Id> res = new Set<Id>();

        // If objList is null or empty or idField is empty, the method returns an empty set
        if(String.isBlank(idField) || objList == null || objList.isEmpty())
        {
            System.debug('# U.getIdSet # objList is null or empty or idField is empty');
            System.debug('# U.getIdSet # END');

            return res;
        }
        // Else the method extracts the id set from the list of objects
        else
        {
            Boolean isPlainField = !idField.contains('.');

            System.debug('# U.getIdSet # isPlainField: ' + isPlainField);

            for(SObject obj : objList)
            {
                System.debug('# U.getIdSet # obj: ' + obj);

                Object val = getSObjectValueWithoutChecks(obj, idField, isPlainField);
                
                System.debug('# U.getIdSet # val: ' + val);
                
                if(val != null)
                {
                    res.add((Id) val);
                }
            }

            System.debug('# U.getIdSet # res: ' + res);
            System.debug('# U.getIdSet # END');

            return res;
        }
    }

    /**
     * @description  Method that extracts a set of strings from a list of objects
     * @param        objList: List of SObject from which get the strings
     * @param        field: API name of the string field
     * @return       Set of strings from list of objects
     */
    public static Set<String> getSet(List<SObject> objList, String field)
    {
        System.debug('# U.getSet # START');
        System.debug('# U.getSet # objList: ' + objList);
        System.debug('# U.getSet # field: ' + field);

        Set<String> res = new Set<String>();
        
        // If objList is null or empty or idField is empty, the method returns an empty set
        if(String.isBlank(field) || objList == null || objList.isEmpty())
        {
            System.debug('# U.getSet # objList is null or empty or idField is empty');
            System.debug('# U.getSet # END');

            return res;
        }
        // Else the method extracts the id set from the list of objects
        else
        {
            Boolean isPlainField = !field.contains('.');

            System.debug('# U.getSet # isPlainField: ' + isPlainField);

            for(SObject obj : objList)
            {
                System.debug('# U.getSet # obj: ' + obj);

                Object val = getSObjectValueWithoutChecks(obj, field, isPlainField);

                System.debug('# U.getSet # val: ' + val);

                if(val != null)
                {
                    res.add(String.valueOf(val));
                }
            }

            System.debug('# U.getSet # res: ' + res);
            System.debug('# U.getSet # END');

            return res;
        }
    }

    /**
     * @description  Method that extracts a map from a list of objects, where the value is the object and the key is a object's field
     * @param        objList: List of SObject from which generate the map
     * @param        field: API name of the field to be used as key
     * @return       Map of objects with a field value as key
     */
    public static Map<String, SObject> keyBy(List<SObject> objList, String field)
    {
        System.debug('# U.keyBy # START');
        System.debug('# U.keyBy # objList: ' + objList);
        System.debug('# U.keyBy # field: ' + field);
        System.debug('# U.keyBy # END');

        return keyBy(objList, field, false);
    }

    /**
     * @description  Method that extracts a map from a list of objects, where the value is the object and the key is one or more object's fields
     * @param        objList: List of SObject from which generate the map
     * @param        keyPattern: String with the pattern of the key, where each tag {fieldName} is a object's field (i.e. {firstName}_{lastName})
     * @param        useRegex: Boolean that indicates if the pattern is a regex or not
     * @return       Map of objects with a pattern as key
     */
    public static Map<String, SObject> keyBy(List<SObject> objList, String keyPattern, Boolean useRegex)
    {
        System.debug('# U.keyBy # START');
        System.debug('# U.keyBy # objList: ' + objList);
        System.debug('# U.keyBy # keyPattern: ' + keyPattern);
        System.debug('# U.keyBy # useRegex: ' + useRegex);
        System.debug('# U.keyBy # END');

        return keyBy(objList, keyPattern, useRegex, false);
    }

    /**
     * @description  Method that extracts a map from a list of objects, where the value is the object and the key is one or more object's fields
     * @param        objList: List of SObject from which generate the map
     * @param        keyPattern: String with the pattern of the key, where each tag {fieldName} is a object's field (i.e. {firstName}_{lastName})
     * @param        useRegex: Boolean that indicates if the pattern is a regex or not
     * @param        allowNulls: Boolean that indicates if null values are considered in key generation
     * @return       Map of objects with a pattern as key
     */
    public static Map<String, SObject> keyBy(List<SObject> objList, String keyPattern, Boolean useRegex, Boolean allowNulls)
    {
        System.debug('# U.keyBy # START');
        System.debug('# U.keyBy # objList: ' + objList);
        System.debug('# U.keyBy # keyPattern: ' + keyPattern);
        System.debug('# U.keyBy # useRegex: ' + useRegex);
        System.debug('# U.keyBy # allowNulls: ' + allowNulls);

        Map<String, SObject> res = new Map<String, SObject>();

        // If the list is null or empty or if keyPattern is not blank, an empty map is returned
        if(objList == null || objList.size() == 0 || String.isBlank(keyPattern))
        {
            System.debug('# U.keyBy # objList is null or empty or keyPattern is blank');
            System.debug('# U.keyBy # END');

            return res;
        }

        // If useRegex is true, the keyPattern is considered a regex, where each tag {fieldName} will be replaced by the value of the field
        if(useRegex)
        {
            Map<String, String> pattern2FieldMap = new Map<String, String>();

            Pattern pat = Pattern.compile('\\{[^\\}]+\\}');
            Matcher m = pat.matcher(keyPattern);
            while(m.find())
            {
                String f = m.group().substringAfter('{').substringBeforeLast('}');

                System.debug('# U.keyBy # f: ' + f);

                pattern2FieldMap.put(m.group(), f);
            }

            System.debug('# U.keyBy # pattern2FieldMap: ' + pattern2FieldMap);

            for(SObject obj : objList)
            {
                String compiledPattern = keyPattern;
                for(String p : pattern2FieldMap.keySet())
                {
                    Boolean isPlainField = !p.contains('.');

                    System.debug('# U.keyBy # p: ' + p);
                    System.debug('# U.keyBy # pattern2FieldMap.get(p): ' + pattern2FieldMap.get(p));
                    System.debug('# U.keyBy # isPlainField: ' + isPlainField);

                    Object value = getSObjectValueWithoutChecks(obj, pattern2FieldMap.get(p), isPlainField);

                    System.debug('# U.keyBy # value: ' + value);

                    if(value != null)
                    {
                        compiledPattern = compiledPattern.replace(p, String.valueOf(value));
                    }
                    else if(allowNulls)
                    {
                        compiledPattern = compiledPattern.replace(p, '');
                    }

                    System.debug('# U.keyBy # compiledPattern: ' + compiledPattern);
                }
                res.put(compiledPattern, obj);
            }
        }
        // If useRegex is false, the keyPattern is considered a tag, where the value of the tag is the field name
        else
        {
            Boolean isPlainField = !keyPattern.contains('.');

            System.debug('# U.keyBy # isPlainField: ' + isPlainField);

            for(SObject obj : objList)
            {
                Object v = getSObjectValueWithoutChecks(obj, keyPattern, isPlainField);

                System.debug('# U.keyBy # v: ' + v);

                if(v != null)
                {
                    res.put(String.valueOf(v), obj);
                }
            }
        }

        System.debug('# U.keyBy # res: ' + res);
        System.debug('# U.keyBy # END');

        return res;
    }

    /**
     * @description  Method that extracts a map from a list of objects, where the value is a list of objects and the key is an object's field
     * @param        objList: List of SObject from which generate the map
     * @param        field: API name of the field to be used as key
     * @return       Map of objects with a field value as key
     */
    public static Map<String, List<SObject>> groupBy(List<SObject> objList, String field)
    {
        System.debug('# U.groupBy # START');
        System.debug('# U.groupBy # objList: ' + objList);
        System.debug('# U.groupBy # field: ' + field);
        System.debug('# U.groupBy # END');

        return groupBy(objList, field, false);
    }

    /**
     * @description  Method that extracts a map from a list of objects, where the value is a list of objects and the key is one or more object's fields
     * @param        objList: List of SObject from which generate the map
     * @param        keyPattern: String with the pattern of the key, where each tag {fieldName} is a object's field (i.e. {firstName}_{lastName})
     * @param        useRegex: Boolean that indicates if the pattern is a regex or not
     * @return       Map of objects with a pattern as key
     */
    public static Map<String, List<SObject>> groupBy(List<SObject> objList, String keyPattern, Boolean useRegex)
    {
        System.debug('# U.groupBy # START');
        System.debug('# U.groupBy # objList: ' + objList);
        System.debug('# U.groupBy # keyPattern: ' + keyPattern);
        System.debug('# U.groupBy # useRegex: ' + useRegex);

        if(useRegex)
        {
            System.debug('# U.groupBy # useRegex is true so groupByRegex is called');
            System.debug('# U.groupBy # END');

            return groupByRegex(objList, keyPattern);
        }

        Map<String, List<SObject>> res = new Map<String, List<SObject>>();
        if(objList == null)
        {
            System.debug('# U.groupBy # objList is null so an empty map is returned');
            System.debug('# U.groupBy # END');

            return res;
        }

        Boolean isPlainField = !keyPattern.contains('.');

        System.debug('# U.groupBy # isPlainField: ' + isPlainField);
        
        for(SObject obj : objList)
        {
            String v = String.valueOf(getSObjectValueWithoutChecks(obj, keyPattern, isPlainField));

            System.debug('# U.groupBy # v: ' + v);

            addToGMap(res, v != null ? v : 'null', obj);
        }

        System.debug('# U.groupBy # res: ' + res);
        System.debug('# U.groupBy # END');

        return res;
    }

    /**
     * @description  Method that extracts a map from a list of objects, where the value is a list of objects and the key is one or more object's fields
     * @param        objList: List of SObject from which generate the map
     * @param        keyPattern: String with the pattern of the key, where each tag {fieldName} is a object's field (i.e. {firstName}_{lastName})
     * @return       Map of objects with a pattern as key
     */
    public static Map<String, List<SObject>> groupByRegex(List<SObject> objList, String keyPattern)
    {
        System.debug('# U.groupByRegex # START');
        System.debug('# U.groupByRegex # objList: ' + objList);
        System.debug('# U.groupByRegex # keyPattern: ' + keyPattern);
        
        Map<String, SObject[]> res = new Map<String, SObject[]>();
        if(objList == null)
        {
            System.debug('# U.groupByRegex # objList is null so an empty map is returned');
            System.debug('# U.groupByRegex # END');

            return res;
        }

        Map<String, String> pattern2FieldMap = new Map<String, String>();

        Pattern pat = Pattern.compile('\\{[^\\}]+\\}');
        Matcher m = pat.matcher(keyPattern);
        while(m.find())
        {
            String f = m.group().substringAfter('{').substringBeforeLast('}');
            pattern2FieldMap.put(m.group(), f);
        }

        System.debug('# U.groupByRegex # pattern2FieldMap: ' + pattern2FieldMap);

        for(SObject obj : objList)
        {
            System.debug('# U.groupByRegex # obj: ' + obj);

            String compiledPattern = keyPattern;
            for(String p : pattern2FieldMap.keySet())
            {
                System.debug('# U.groupByRegex # p: ' + p);
                System.debug('# U.groupByRegex # pattern2FieldMap.get(p): ' + pattern2FieldMap.get(p));

                String value = String.valueOf(getSObjectValueWithoutChecks(obj, pattern2FieldMap.get(p), !p.contains('.')));

                System.debug('# U.groupByRegex # value: ' + value);

                compiledPattern = compiledPattern.replace(p, value == null ? 'null' : value);
            }
            addToGMap(res, compiledPattern, obj);
        }

        System.debug('# U.groupByRegex # res: ' + res);
        System.debug('# U.groupByRegex # END');

        return res;
    }

    /**
     * @description  Method that add an object to a map of objects where the value is a list of objects and the key is a pattern
     * @param        m: Map of objects where the value is a list of objects and the key is a pattern
     * @param        key: Key of the map
     * @param        obj: Object to add
     * @return       void
     */
    public static void addToGMap(Map<String, List<SObject>> m, String key, SObject value)
    {
        System.debug('# U.addToGMap # START');
        System.debug('# U.addToGMap # m: ' + m);
        System.debug('# U.addToGMap # key: ' + key);
        System.debug('# U.addToGMap # value: ' + value);

        if(!m.containsKey(key))
        {
            m.put(key, new List<SObject>{});
        }
        m.get(key).add(value);

        System.debug('# U.addToGMap # m: ' + m);
        System.debug('# U.addToGMap # END');
    }

    /**
     * @description  Method that reverses the order of the elements in a list
     * @param        objList: List that will be reversed
     * @return       List of object reversed
     */
    public static List<Object> reverse(List<Object> objList)
    {
        System.debug('# U.reverse # START');
        System.debug('# U.reverse # objList: ' + objList);
        
        List<Object> res = new List<Object>();
        // If objList is null, an empty list is returned
        if(objList == null)
        {
            System.debug('# U.reverse # objList is null, returning an empty list');
            System.debug('# U.reverse # END');
            
            return res;
        }

        res = objList.clone();
        for(Integer i = 0; i < objList.size(); i++)
        {
            res[objList.size() - 1 - i] = objList[i];
        }

        System.debug('# U.reverse # res: ' + res);
        System.debug('# U.reverse # END');

        return res;
    }

    /**
     * @description  Method that filters a list of SObjects, based on the value of a field
     * @param        coll: List to be filtered
     * @param        field: API name of the field to filter on
     * @param        value: Value of the field to filter on
     * @return       List filtered
     */
    public static List<SObject> filter(List<SObject> coll, String field, Object value)
    {
        System.debug('# U.filter # START');
        System.debug('# U.filter # coll: ' + coll);
        System.debug('# U.filter # field: ' + field);
        System.debug('# U.filter # value: ' + value);
        System.debug('# U.filter # END');

        return filter(coll, field, value, true);
    }

    /**
     *  Filtra la lista di oggetti in input sulla base del valore di un campo
     *  @coll La lista di oggetti
     *  @field Il nome api del campo
     *  @value il valore del campo
     *  @includeOrExclude Se true, l'oggetto è presente nella lista filtrata solo se il valore del campo è uguale a value, se false invece l'oggetto è
     *                    presente solo se il valore del campo NON è uguale a value
     */
    /**
     * @description  Method that filters a list of SObjects, based on the value of a field
     * @param        coll: List to be filtered
     * @param        field: API name of the field to filter on
     * @param        value: Value of the field to filter on
     * @param        includeOrExclude: If true, all objects in list that match value are returned; if false, all objects that DO NOT match value are returned
     * @return       List filtered
     */
    public static List<SObject> filter(List<SObject> coll, String field, Object value, Boolean includeOrExclude)
    {
        System.debug('# U.filter # START');
        System.debug('# U.filter # coll: ' + coll);
        System.debug('# U.filter # field: ' + field);
        System.debug('# U.filter # value: ' + value);
        System.debug('# U.filter # includeOrExclude: ' + includeOrExclude);

        if(value != null && (value instanceof Set<String> || value instanceof Set<Id>))
        {
            return filter(coll, field, (Set<String>) value, includeOrExclude);
        }

        List<SObject> res = new List<SObject>{};
        if(coll == null)
        {
            System.debug('# U.filter # coll is null, so an empty list is returned');
            System.debug('# U.filter # END');

            return res;
        }

        for(SObject x : coll)
        {
            Object val = getSObjectValue(x, field);

            System.debug('# U.filter # val: ' + val);
            System.debug('# U.filter # value == val: ' + value == val);

            if((value == val && includeOrExclude) || (!includeOrExclude && value != val))
            {
                res.add(x);
            }
        }

        System.debug('# U.filter # res: ' + res);
        System.debug('# U.filter # END');
        
        return res;
    }

    /**
     *  Filtra la lista di oggetti in input sulla base di uno o più valori di un campo
     *  @coll La lista di oggetti
     *  @field Il nome api del campo
     *  @value L'insieme dei valori da controllare. I valori sono messi in OR
     */
    public static SObject[] filter(SObject[] coll, String field, Set<String> value) {
        return filter(coll, field, value, true);
    }

    /**
     *  Filtra la lista di oggetti in input sulla base di uno o più valori di un campo
     *  @coll La lista di oggetti
     *  @field Il nome api del campo
     *  @value L'insieme dei valori da controllare. I valori sono messi in OR
     *  @includeOrExclude Se true, l'oggetto è presente nella lista filtrata solo se il valore del campo è uguale a value, se false invece l'oggetto è
     *                    presente solo se il valore del campo NON è uguale a value
     */
    public static SObject[] filter(SObject[] coll, String field, Set<String> value, Boolean includeOrExclude) {
        SObject[] res = new SObject[]{};
        if(coll == null) return res;
        for(SObject x : coll) {
            Object val = getSObjectValue(x, field);
            if((includeOrExclude && value.contains((String) val)) || (!includeOrExclude && !value.contains((String) val))) res.add(x);
        }
        return res;
    }

    private static Map<String, SObject> profilesCache = new Map<String, SObject>();

    public static Map<String, SObject> getProfiles() {
        if(profilesCache.values().isEmpty()) {
            Map<String, SObject> temp = U.keyBy([Select Id, Name From Profile], 'Name');
            for(String key : temp.keySet()) {
                profilesCache.put(key, temp.get(key));
            }
        }
        return profilesCache;
    }

    /**
     *  Restituisce una mappa DeveloperName => RecordType di tutti i recordtypes di un oggetto
     *  @obj Il nome dell'oggetto di cui si vogliono recuperare i recordType
     */
    private static Map<String, Map<String, SObject>> rtCache = new Map<String, Map<String, SObject>>();
    private static Map<String, Map<String, Id>> newRtCache = new Map<String, Map<String, Id>>();
    public static Map<String, SObject> getRecordTypes(String sobj) {
        if(!rtCache.containsKey(sobj)) rtCache.put(sobj, keyBy([SELECT
          Id,
          SObjectType,
          Name,
          DeveloperName,
          IsActive,
          Description
          FROM RecordType
          WHERE SObjectType = :sobj
        ], 'DeveloperName'));
        return rtCache.get(sobj);
    }

    public static Map<String, Id> getRtMap(String sobj) {
        if(!newRtCache.containsKey(sobj)) {
            Map<String, Id> res = new Map<String, Id>();
            for(Schema.RecordTypeInfo rtInfo : Schema.getGlobalDescribe().get(sobj).getDescribe().getRecordTypeInfosByDeveloperName().values()) {
                res.put(rtInfo.getDeveloperName(), rtInfo.getRecordTypeId());
            }
            newRtCache.put(sobj, res);
        }
        return newRtCache.get(sobj);
    }

    /**
     *  Restituisce un set dato una lista in input
     *  @l Il nome della lista che si vuole convertire
     */
    public static Set<String> toSet(String[] l) {
        Set<String> res = new Set<String>();
        if(l != null) res.addAll(l);
        return res;
    }

    /**
     *  Restituisce una lista dato un set in input
     *  @s Il nome del set che si vuole convertire
     */
    public static List<String> toList(Set<String> s) {
        String[] res = new String[]{};
        if(s != null) res.addAll(s);
        return res;
    }

    /**
     *  Restituisce una lista dato un set in input
     *  @s Il nome del set che si vuole convertire
     */
    public static List<Id> toIdList(Set<Id> s) {
        Id[] res = new Id[]{};
        if(s != null) res.addAll(s);
        return res;
    }

    /**
     *  Valorizza il campo field col valore value per tutta la lista di objs
     */
    public static void massSet(SObject[] objs, String field, Object value) {
        for(SObject o : objs) {
            o.put(field, value);
        }
    }

    /**
    *  Restituisce una mappa valore => label relativa ad una picklist
    *  @field Il campo picklist di cui si vuole ottenere la mappa
    */
    public static Map<String, String> getPicklistMap(Schema.SObjectField field) {
        return getPicklistMap(field.getDescribe());
    }

    public static Map<String,String> getPicklistMap(Schema.DescribeFieldResult dfr) {
        Map<String, String> res = new Map<String,String>();
        Schema.PicklistEntry[] pickValues = dfr.getPickListValues();
        for(Schema.PicklistEntry ple : pickValues) {
            res.put(ple.getValue(), ple.getLabel());
        }
        return res;
    }

    /**
     * Restituisce l'indirizzo IP dell'utente connesso
     */
    public static String getUserIPAddress() {
        String ipAddress = '';
        Map<String, String> myMap = Auth.SessionManagement.getCurrentSession();
        ipAddress = myMap.get('SourceIp');

        return ipAddress;
    }

    public static void setIfEmpty(SObject o, String field, Object value) {
        Object v = o.get(field);
        if(v == null || (v instanceof String && v == '')) o.put(field, value);
    }

    public static Boolean isAsync() {
        return System.isBatch() || System.isFuture() || System.isQueueable();
    }

    public static String substring(String x, Integer startIdx, Integer endIdx) {
        if(String.isBlank(x)) return x;
        else if(endIdx <= startIdx) return '';
        else if(x.length() <= startIdx) return '';
        return x.substring(startIdx, x.length() < endIdx ? x.length() : endIdx);
    }

    public static Map<String, Schema.SObjectField> getFieldsDescribeForSObject(String sObjectName) {
        return getGlobalDescribe().get(sObjectName.toLowerCase()).getDescribe().fields.getMap();
    }

    public static List<String> getCreatableFieldsNamesForSObject(String sObjectName) {
        Map<String, Schema.SObjectField> temp = getFieldsDescribeForSObject(sObjectName);
        List<String> result = new List<String>();
        for(String fieldName : temp.keySet()) {
            if((temp.get(fieldName)).getDescribe().isCreateable()) result.add(temp.get(fieldName).getDescribe().getName());
        }
        return result;
    }

    public static SObject[] optional(SObject[] input) {
        if(input != null) return input;
        return new List<SObject>();
    }

    public static SObject[] join(SObject[] list1, SObject[] list2) {
        SObject[] res = new SObject[]{};
        res.addAll(list1);
        res.addAll(list2);
        return res;
    }

    public static Set<String> join(Set<String> set1, Set<String> set2) {
        Set<String> finalSet = new Set<String>(set1);
        finalSet.addAll(set2);
        return finalSet;
    }

    /**
      *  Simile allo split standard di SFDC, ma gestisce il caso di stringa vuota o nulla in ingresso
      */
    public static String[] split(String value, String separator) {
        if(String.isBlank(value)) return new String[]{};
        return value.split(separator);
    }

    public static String[] splitAndTrimToList(String stringToSplit, String separator) {
        String[] result = new String[]{};
        if (String.isNotBlank(stringToSplit)) {
            String[] tmp = stringToSplit.split(separator);
            for (String s : tmp) {
                result.add(s.trim());
            }
        }
        return result;
    }

    /**
     * @description Chunks splits a string into chunks of specified length. Whitespace are preserved
     * @param  stringToChunk the string to split into chunks
     * @param  chunkLength   length of the chunk
     * @return               array of chunks
     */
    public static String[] chunks(String stringToChunk, Integer chunkLength) {
        String[] result = new String[]{};
        if (String.isNotBlank(stringToChunk)) {
            for(Integer i = 0; i < stringToChunk.length(); i += chunkLength) {
                Integer endIndex = i + chunkLength < stringToChunk.length() ? i + chunkLength : stringToChunk.length();
                result.add(stringToChunk.substring(i, endIndex));
            }
        }
        return result;
    }

    public static String addToMultiselect(String multiselect, String value) {
        Set<String> valuesSet = new Set<String>();
        String[] values = new String[]{};
        valuesSet.addAll(split(multiselect, ';'));
        valuesSet.addAll(split(value, ';'));
        values.addAll(valuesSet);
        values.sort();
        return String.join(values, ';');
    }

    public static String replaceInMultiselect(String multiselect, String oldValue, String newValue) {
        Set<String> valuesSet = new Set<String>();
        valuesSet.addAll(split(multiselect, ';'));
        valuesSet.removeAll(split(oldValue, ';'));
        if(newValue != null) valuesSet.add(newValue);
        String[] values = toList(valuesSet);
        values.sort();
        return String.join(values, ';');
    }


    public static List<List<Object>> doPartition(List<Object> totalList, Integer splitSize, Type destType){
        List<List<Object>> result = (List<List<Object>>)destType.newInstance();

        List<Object> destTypelist = totalList.clone();
        destTypelist.clear();
        List<Object> tempList = destTypelist.clone();
        Integer count = 0;
        Integer size = totalList.size();
        for(Integer i=0; i<=size - 1; i++){
            tempList.add(totalList.get(i));
            ++count;
            if(count == splitSize || (count < splitSize && i == size - 1)) {
                result.add(tempList);
                tempList = destTypelist.clone();
                count = 0;
            }
        }
        return result;
    }

    public static String getRecordTypeId(String objectName, String recTypeDevName){
        Schema.DescribeSObjectResult describeResult = Schema.getGlobalDescribe().get(objectName).getDescribe();
        return describeResult.getRecordTypeInfosByDeveloperName().get(recTypeDevName).getRecordTypeId();
    }

    /**
    * Filtra una lista di oggetti e se tutti i field sono null lo rimuove (utilizza liste migliori a livello di performance)
    */
    public static SObject[] filterListNullOr(SObject[] objList, String[] fields) {
        SOBject[] sobjs = new List < SOBject > ();
        for(SOBject so : objList){
            Boolean notRemove = false;
            for (String f: fields) {
                if(so.get(f) != null) notRemove = true;
            }
            if(notRemove) sobjs.add(so);
        }
        return sobjs;
    }

    public static String getSaveResultStringError(Database.SaveResult sr) {
        String[] stringErrors = new String[]{};
        if (!sr.isSuccess()) {
            Database.Error[] errors = sr.getErrors();
            for (Database.Error err : errors) {
                stringErrors.add(err.getMessage());
            }
        }
        return String.join(stringErrors, '. ');
    }

    public static Boolean isBatchRunning(String batchName) {
        return isBatchRunning(new Set<String> {batchName});
    }

    public static Boolean isBatchRunning(Set<String> batchNameSet) {
        AsyncApexJob[] tmp = [
          SELECT Id, ApexClass.Name, Status
          FROM AsyncApexJob
          WHERE Status IN ('Holding', 'Preparing', 'Processing', 'Queued') AND
          ApexClass.Name IN :batchNameSet
        ];

        return tmp.isEmpty() ? false : true;
    }
}