public with sharing class TestDataFactory {
    
    
    public static CollaborationGroup ConstructCollaborationGroup(){
        CollaborationGroup gr = new CollaborationGroup();
        gr.Name = 'TEST' + Constants.INVENTORY_ANNOUNCEMENTS;
        gr.CanHaveGuests = false;
        gr.IsArchived = false; 
        gr.CollaborationType = 'public'; 
        gr.IsAutoArchiveDisabled = false; 
        return gr; 
        
    }
    
    
    public static List<Product2> ConstructProducts(Integer cnt){
        List<Product2> prList = new List<Product2>();
        
        for(Integer i = 1; i <= cnt; ++i){
            Product2 p = new Product2();
            p.name = 'Product' + i; 
            p.isActive = true; 
            p.Family = Constants.PRODUCT_FAMILY.get(Math.mod(i,4)).getValue();
            p.Initial_Inventory__c = 10; 
            prList.add(p);
        }
        return prList; 
    }
    
    
    public static List<PricebookEntry> ConstructPricebookEntries(List<Product2> prods){
        List<PricebookEntry> pB = new List<PricebookEntry>();
        
        for(Product2 pr: prods){
            PricebookEntry p = new PricebookEntry();
            p.UnitPrice = 1; 
            p.PriceBook2Id = Constants.STANDARD_PRICEBOOK_ID;
            p.Product2Id = pr.Id;
            p.isActive = true; 
            pB.add(p);
        }
        return pB; 
        
    }
    
    
    public static List<Account> constructAccounts(Integer cnt){
        List<Account> aList= new List<Account>();
        for(Integer i = 0; i < cnt; ++i){
            Account a = new Account(); 
            a.Name = 'Acc' + i; 
            aList.add(a);
            
        }
        return aList; 
    }
    
    
    public static List<Contact> ConstructContacts(Integer cnt, List<Account> accts){
        List<Contact> conList= new List<Contact>();
        for(Integer i = 0; i <cnt; ++i){
            Integer j = Math.mod(i, accts.size());
            Contact con = new Contact();
            con.LastName = 'Con' + i;
            con.AccountId = accts.get(j).Id;
            conList.add(con);
        }
        return conList; 
    }
    
    
    public static List<Order> ConstructOrders(Integer cnt, List<Account> accts){
        List<Order> oList = new List<Order>();
        for(Integer i = 0; i <cnt; ++i){
            Order o = new Order();
            o.Name = 'Order' + i; 
            o.AccountId = accts[Math.mod(i,accts.size())].Id;
            o.Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID;
            o.Status = 'Draft'; 
            o.EffectiveDate = Date.today(); 
            oList.add(o);
        }
        return oList; 
    }
    
    
    public static List<OrderItem> constructOrderItems(integer cnt, list<pricebookentry> pbes, list<order> ords){
        List<OrderItem> oItemList = new List<OrderItem>();
        Integer lenPBES = pbes.size();
        Integer lenORDS = ords.size();
        for(Integer i = 0; i <cnt; ++i){
            OrderItem oI = new OrderItem();
            oI.Quantity= Constants.DEFAULT_ROWS;
            oI.UnitPrice = 1; 
            oI.OrderId = ords[Math.mod(i, lenORDS)].Id;
            oI.PricebookEntryId = pbes[Math.mod(i, lenPBES)].Id;
            
            oItemList.add(oI);
            
        }
        return oItemList;
    }
    
    
    public static void InsertTestData(Integer cnt){
        insert ConstructCollaborationGroup();
        
        List<Product2> prList = ConstructProducts(cnt);
        insert prList;
        
        List<PriceBookEntry> pBEntryList = ConstructPricebookEntries(prList);
        insert pBEntryList;
        
        List<Account> accs = constructAccounts(cnt);
        insert accs;
        
        insert ConstructContacts(cnt,accs);
        
        
        List<Order> orders = ConstructOrders(cnt,accs);
        insert orders;
        
        insert ConstructOrderItems(cnt,pBEntryList, orders);
        
        
    }
    
    public static void VerifyQuantityOrdered(Product2 originalProduct, Product2 updatedProduct, Integer qtyOrdered){
        System.assertEquals((updatedProduct.Quantity_Ordered__c - originalProduct.Quantity_Ordered__c) , qtyOrdered);
    }
    
}
