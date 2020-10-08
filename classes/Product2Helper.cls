public class Product2Helper {
    static List<CollaborationGroup> COLLABORATION_GROUP = [
        SELECT Id
        FROM CollaborationGroup
        WHERE Name =: Constants.INVENTORY_ANNOUNCEMENTS
        OR Name = :('TEST'+Constants.INVENTORY_ANNOUNCEMENTS )
        LIMIT 1
    ];
    
    
    public static void AfterUpdate(List<Product2> newL, List<Product2> oldL){
        List<Product2> needsAnnouncement = new List<Product2>();
        Map<String,Inventory_Setting__mdt> m = new Map<String,Inventory_Setting__mdt> ();
        
        for(Inventory_Setting__mdt iSetting: [Select Id, DeveloperName, Low_Quantity_Alert__c From Inventory_Setting__mdt]){
            m.put(iSetting.DeveloperName, iSetting);
        }
        
        
        
        for(Product2 n: newL){
            if(m.get(n.Family) != null && n.Quantity_Remaining__c < m.get(n.family).Low_Quantity_Alert__c)needsAnnouncement.add(n);
        }
        PostAlerts(needsAnnouncement);
    }
    
    
    public static void PostAlerts(List<Product2> productList){
        List<ConnectApi.AnnouncementInput> toPost = new List<ConnectApi.AnnouncementInput>();
        for ( Product2 p : productList ){
            ConnectApi.AnnouncementInput inp = new ConnectApi.AnnouncementInput();
            inp.expirationDate = Date.today().addDays(1);
            inp.sendEmails = false; 
            ConnectApi.MessageBodyInput bodyI = new ConnectApi.MessageBodyInput();
            ConnectApi.TextSegmentInput textI = new ConnectApi.TextSegmentInput(); 
            textI.text = p.Name + ' , ' + Constants.INVENTORY_LEVEL_LOW;
            bodyI.messageSegments = new List<ConnectApi.TextSegmentInput>();
            bodyI.messageSegments.add(textI);
            inp.body = bodyI;
            inp.parentId = Collaboration_Group[0].Id;
            toPost.add(inp);
        }
        
        AnnouncementQueueable an = new AnnouncementQueueable();
        an.toPost = toPost;
        System.enqueueJob(an);
    }
}
