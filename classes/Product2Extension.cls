public class Product2Extension {
    
    public List<ProductWrapper> productsToInsert {get;set;}
    
    public Product2Extension(ApexPages.StandardController controller){
        productsToInsert = new List<ProductWrapper>();
        addRows();
    }
    
    public void AddRows(){
        for ( Integer i=0; i< Constants.DEFAULT_ROWS; i++ ){
            productsToInsert.add(new ProductWrapper());
        }
    }
    
    public List<ChartHelper.ChartData> GetInventory(){
        return ChartHelper.GetInventory();
    }
    
    public List<SelectOption> GetFamilyOptions(){
        List<SelectOption> opt = new List<SelectOption>();
        opt.add(new SelectOption(Constants.SELECT_ONE, Constants.SELECT_ONE));
        
        for(PicklistEntry p: Constants.PRODUCT_FAMILY){
            opt.add(new SelectOption(p.getValue(), p.getLabel()));
        }
        return opt;
    }
    
    
    
    public PageReference Save(){
        Savepoint s1 = Database.setSavepoint();
        
        List<Product2> prods = new List<Product2>();
        List<PriceBookEntry> pricebookEs = new List<PriceBookEntry>();
        
        for(ProductWrapper p : productsToInsert){
            if(p.priceBookEntryRecord != null &&  p.productRecord != null){
                if(p.productRecord.Name != null && p.productRecord.Name != '' && p.productRecord.Family != null && p.productRecord.Family != '' && Constants.SELECT_ONE != p.productRecord.Family && p.productRecord.Initial_Inventory__c != null && p.pricebookEntryRecord.UnitPrice != null ){
                    prods.add(p.productRecord); 
                    PriceBookEntry pr = p.pricebookEntryRecord;
                    pr.Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID;
                    pr.IsActive= true;
                    pricebookEs.add(pr);
                }
            }
        }
        
        
        if(prods != null && prods.size() > 0){
            insert prods;
            for(Integer i = 0; i < pricebookEs.size(); ++i){
                pricebookEs[i].Product2Id = prods[i].Id; 
            }
            
            if(pricebookEs != null && pricebookEs.size() > 0){
                insert pricebookEs;   
            } 
            apexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO,prods.size()+' Inserted'));
        }
        else{
            Database.rollback(s1);
            apexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, Constants.ERROR_MESSAGE));
        }
        productsToInsert.clear(); 
        addRows();  
        return null;
    }
    
    
    
    public class ProductWrapper{
        public Product2 productRecord {get;set;}
        public PriceBookEntry pricebookEntryRecord {get;set;}
        
        public ProductWrapper(){
            productRecord  = new Product2(Initial_Inventory__c =0);
            pricebookEntryRecord  = new PriceBookEntry(Unitprice=0.0);
        }
    }
    
}
