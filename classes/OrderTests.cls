@isTest (seeAllData=false)
private class OrderTests {
    
    @TestSetup
    static void SetupTestData(){
        TestDataFactory.InsertTestData(20);
    } 
    
    
    
    static testmethod void OrderUpdate_UnitTest (){
        Product2 P = [Select Quantity_Ordered__c , Name, Id FROM Product2 LIMIT 1];
        Order O = [Select Status , Name, Id FROM Order LIMIT 1];
        O.Status= Constants.ACTIVATED_ORDER_STATUS;
        update O;
        
        Product2 newP = [Select Quantity_Ordered__c , Name, Id FROM Product2 LIMIT 1];
        
        TestDataFactory.VerifyQuantityOrdered(P, newP, Constants.DEFAULT_ROWS);
        
    }
    
    static testmethod void OrderExtension_UnitTest (){
        Pagereference p = Page.ORderEdit;
        Test.setCurrentPage(p);
        
        Order o = [Select Status, Id FROM Order Limit 1];
        ApexPages.StandardController c = new ApexPages.StandardController(o);
        OrderExtension ex = new OrderExtension(c);
        
        System.assertEquals(5, ex.orderItemList.size());
        
        ex.selectedFamily = 'Boss';
        ex.SelectFamily();
        ex.OnFieldChange();
        ex.First();
        ex.Next();
        ex.Previous();
        ex.Last();
        ex.GetHasNext();
        ex.GetPageNumber();
        ex.GetHasPrevious();
        ex.GetTotalPages();
        ex.GetFamilyOptions();
        ex.Save();
        
        ChartHelper.GetInventory();
    }
}
