public without sharing class OrderHelper {
    public static void AfterUpdate(List<Order> newList, List<Order> oldList){
        Set<Id> orderIds = new Set<Id>();
        for ( Integer i=0; i<newList.size(); i++ ){
            if ( (newList[i].Status != null && oldList[i].Status != null) && newList[i].Status ==Constants.ACTIVATED_ORDER_STATUS && oldList[i].Status != Constants.ACTIVATED_ORDER_STATUS){
                orderIds.add(newList[i].Id);
            }
        }
        RollUpOrderItems(orderIds); 
    }
    
    
    public static void RollUpOrderItems(Set<Id> activatedOrderIds){
        Map<Id,Product2> productMap = new Map<Id,Product2>();
        Set<Id> prodIDs = new Set<Id>();
        
        for(OrderItem i: [SELECT Id,Product2Id , quantity FROM OrderItem WHERE orderId in :activatedOrderIds]){
            prodIDs.add(i.Product2Id);
        }
        
        productMap = new Map<Id,Product2>([SELECT id,Quantity_Ordered__c FROM Product2 WHERE Id in : prodIDs]);
        AggregateResult[] ar = [ SELECT Product2Id, sum(Quantity) totalQ FROM OrderItem WHERE Product2Id in: productMap.keySet() Group By Product2Id];
        for(AggregateResult a: ar){
            productMap.get((String)a.get('Product2Id')).Quantity_Ordered__c = Integer.valueOf(a.get('totalQ'));
        }
        
        if(productMap != null && productMap.size() > 0 ) update productMap.values();
    }
    
}
