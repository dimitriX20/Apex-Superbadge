@isTest (seeAllData=true)
private class Product2Tests {
    static TestMethod void Product2Extension_UnitTest(){
        PageReference pageR = page.Product2New;
        Product2 product = new Product2(Name='Pro', isActive = true);
        ApexPages.StandardController con = new ApexPages.StandardController(product); 
        
        Test.startTest();
        Product2Extension ext = new Product2Extension(con);
        System.assertEquals(Constants.DEFAULT_ROWS, ext.productsToInsert.size());  
        ext.addRows();
        System.assertEquals(2* Constants.DEFAULT_ROWS, ext.productsToInsert.size()); 
        
        for(Integer i = 0; i < Constants.DEFAULT_ROWS; ++i){
            Product2 pr = new Product2(Name= 'product' + i, Initial_Inventory__c = 10, isActive = true, family = Constants.PRODUCT_FAMILY.get(math.mod(i, 4)).getValue());
            ext.productsToInsert.get(i).productRecord = pr;
            PricebookEntry E = new PricebookEntry(UnitPrice = 100, isActive= true);
            ext.productsToInsert.get(i).pricebookEntryRecord = E;
        }
        ext.save();
        ext.GetFamilyOptions();
        ext.GetInventory();
        List<Product2> prods = [Select Id FROM Product2];
        System.assertEquals(Constants.DEFAULT_ROWS, prods.size());
        Test.stopTest();
    }
    
    
    
    static TestMethod void Product2Trigger_UnitTest (){
        Test.startTest();
        
        Product2 pr = new Product2();
        pr.Family = 'Boss';
        pr.IsActive = true;
        pr.Name = 'Hugo';
        pr.Quantity_Ordered__c = 1;
        pr.Initial_Inventory__c = 10;
        insert pr;
        
        CollaborationGroup c = new CollaborationGroup();
        c.Name = 'HUGO BOSS GRPUP' + Constants.INVENTORY_ANNOUNCEMENTS;
        c.CollaborationType = 'Public';
        c.Description = 'as the name suggests: its the boss group!';
        insert c;
        
        pr.Quantity_Ordered__c = 1007;
        update pr; 
        
        Test.stopTest();
    }
    
}
