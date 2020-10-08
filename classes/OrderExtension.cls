public class OrderExtension {
    
    public Order orderRecord {get;set;}
    public List<OrderItem> orderItemList {get;set;}
    public String selectedFamily {get;set;}
    public List<chartHelper.chartData> pieData {get;set;}
    public Decimal total {get;set;}
    
    public Map<Id,OrderItem> orderItemMap;
    ApexPages.StandardSetController standardSetController;
    
    public OrderExtension(ApexPages.StandardController standardController){
        orderRecord = (Order)standardController.getRecord();
        orderItemMap = new Map<id,OrderItem>();
        if ( orderRecord.Id != null ){
            orderRecord = queryOrderRecord(orderRecord.Id);
        }
        loadOrderItemData();
        loadPricebookEntry();
    }
    
    
    public void loadPricebookEntry(){
        String query = 'SELECT Id, PriceBook2Id, Product2Id, UnitPrice, Product2.Name, Product2.Quantity_Remaining__c, Product2.Family, Name FROM PricebookEntry WHERE isActive = true';
        if(String.isNotBlank(selectedFamily) && selectedFamily != Constants.SELECT_ONE){
            query += ' AND Product2.Family = \'' + selectedFamily + '\'';
        }
        standardSetController = new ApexPages.StandardSetController(Database.getQueryLocator(query));
        standardSetController.setPageSize(Constants.DEFAULT_ROWS);
        
        loadOrderItem();
    }
    
    
    public void loadOrderItemData(){
        for(Orderitem item : orderRecord.OrderItems){
            orderItemMap.put(item.Product2Id, item);
        }
        loadChart();
    }
    
    public void loadOrderItem(){
        orderItemList = new List<OrderItem>();
        
        if(standardSetController.getRecords() != null && standardSetController.getRecords().size() > 0){
            for(sObject ob: standardSetController.getRecords()){
                PriceBookEntry en = (PricebookEntry)ob;
                
                if(orderItemMap.containsKey(en.Product2Id)){
                    orderItemList.add(orderItemMap.get(en.Product2Id));
                }
                else{
                    OrderItem it = new OrderItem(
                        Quantity = 0,
                        PriceBookEntryId = en.Id,
                        Product2Id = en.Product2Id,
                        Product2 = en.Product2,
                        UnitPrice = en.UnitPrice
                    );
                    orderItemList.add(it);
                    orderItemMap.put(en.Pricebook2Id, it);
                }
            }
            
            
        }
    }
    
    public void loadChart(){
        this.total = 0; 
        pieData = new List<ChartHelper.ChartData>();
        for(Orderitem item :orderItemMap.values()){
            pieData.add(new ChartHelper.ChartData(item.Product2.Name, (item.UnitPrice * Item.Quantity)));
            total += (item.UnitPrice * item.Quantity);
        }
    }
    
    
    public void OnFieldChange(){
        for(OrderItem item: orderItemList){
            orderItemMap.put(item.Product2Id, item);
        }
        loadChart();
    }
    
    
    public void SelectFamily(){
        loadPricebookEntry();
    }
    
    
    public void Save(){
        Savepoint s1 = Database.setSavepoint();
        
        try{
            if(orderRecord.Pricebook2Id == null){
                orderRecord.Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID;
            }
            upsert orderRecord; 
            
            List<OrderItem> ordDelete = new List<OrderItem>();
            List<OrderItem> ordUpsert = new List<OrderItem>();
            
            for(OrderItem o : orderItemMap.values()){
                if(o.Quantity > 0){
                    if(o.OrderId == null){
                        o.OrderId = orderRecord.Id;
                    }
                    ordUpsert.add(o);
                }
                else if(o.id != null){
                    ordDelete.add(new OrderItem(id = o.Id));
                    o.Id = null; 
                }
            }
            upsert ordUpsert;
            delete ordDelete;
        }
        catch(Exception e){
            Database.rollback(s1);
            apexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO, Constants.ERROR_MESSAGE));
        }
    }
    
    
    public void First(){
        standardSetController.first();
        loadOrderItem();
    }
    
    
    public void Next(){
        standardSetController.next();
        loadOrderItem();
    }
    
    
    public void Previous(){
        standardSetController.previous();
        loadOrderItem();
    }
    
    
    public void Last(){
        standardSetController.last();
        loadOrderItem();
    }
    
    
    public Boolean GetHasPrevious(){
        return standardSetController.getHasPrevious();
    }
    
    
    public Boolean GetHasNext(){
        return standardSetController.getHasNext();
    }
    
    public Integer GetTotalPages(){
        return (Integer)math.ceil(standardSetController.getResultSize() / (Decimal) Constants.DEFAULT_ROWS);
    }
    
    
    public Integer GetPageNumber(){
        return standardSetController.getPageNumber();
    }
    
    
    
    public List<SelectOption> GetFamilyOptions(){
        List<SelectOption> opt = new List<SelectOption>();
        opt.add(new SelectOption(Constants.SELECT_ONE, Constants.SELECT_ONE));
        
        for(PicklistEntry p: Constants.PRODUCT_FAMILY){
            opt.add(new SelectOption(p.getValue(), p.getLabel()));
        }
        return opt;
    }
    
    
    public static Order QueryOrderRecord(Id orderId){
        return [
            SELECT Id, AccountId, EffectiveDate, Name, Status, Pricebook2Id,
            (
                SELECT Id, OrderId, Quantity, UnitPrice, PricebookEntryId, Product2Id,
                Product2.Name, Product2.Family, Product2.Quantity_Remaining__c
                FROM OrderItems
            )
            FROM Order
            WHERE Id = :orderId
        ];
    }
    
}
