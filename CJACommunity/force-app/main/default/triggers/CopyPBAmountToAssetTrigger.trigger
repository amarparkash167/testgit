trigger CopyPBAmountToAssetTrigger on Asset (before insert) {
    
    CopyPricebookAmounttoAsset copyPBAmountToAsset = new CopyPricebookAmounttoAsset();
    
    Set<Id> setOfContractIds = new Set<Id>();
    
    for(Asset a : Trigger.New) {
        
        setOfContractIds.add(a.contract__c);
    } 
    
    List<Contract> listOfContracts = copyPBAmountToAsset.getListOfContracts(setOfContractIds);
    Map<Id,Id> mapOfContractIdWithPBId = copyPBAmountToAsset.getMapOfContractIdWithPBId(listOfContracts);
    set<Id> setOfPBIds = copyPBAmountToAsset.getSetOfPBIds(mapOfContractIdWithPBId.values());
    List<PriceBookEntry> listOfPBE = copyPBAmountToAsset.getListOfPBE(setOfPBIds);
    Map<String, PriceBookEntry> mapOfProAndPBWithPBE = copyPBAmountToAsset.getMapOfProAndPBWithPBE(listOfPBE);
    
    
    for(Asset a : Trigger.New) {
        
        Id PB = mapOfContractIdWithPBId.get(a.contract__c);
    	
        if(PB!=null){
        
            PriceBookEntry PBE = mapOfProAndPBWithPBE.get(a.Product2Id + '-' + PB);
            System.debug('PriceBook Entry'+PBE);
            if(PBE!=null)
	            a.Hourly_Rate_per_role__c = PBE.UnitPrice;
         }
    } 
    
}