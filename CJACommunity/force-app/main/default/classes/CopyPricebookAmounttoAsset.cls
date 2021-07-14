public class CopyPricebookAmounttoAsset {


    // Get Contract List of Set of Contract Ids
    public List<Contract> getListOfContracts(Set<Id> setOfContractIds){
        
        List<Contract> listOfContracts = [Select id, name, pricebook2Id from Contract where Id In: setOfContractIds];
        return listOfContracts;
    }
    
    // Get Map of Contract Ids with PriceBookId
    public Map<Id,Id> getMapOfContractIdWithPBId(List<Contract> listOfContract){
        
        Map<Id,Id> mapOfContractIdWithPBId = new Map<Id,Id>();
        for(Contract contr: listOfContract){
            
            mapOfContractIdWithPBId.put(contr.Id,contr.pricebook2Id);
        }
        
        return mapOfContractIdWithPBId;
    }
    
    // Convert List of PB Ids to PB 
    public set<Id> getSetOfPBIds(List<Id> listOfPBIds){
        
        set<Id> setOfPBIds = new set<Id>();
        
        for(Id PBId: listOfPBIds){
            
            setOfPBIds.add(PBId);
        }
        
        return setOfPBIds;
    }
    
    // Get List of Price Book Entry of all the Products
    public List<PriceBookEntry> getListOfPBE(Set<Id> setOfPBIds){
        
        List<PriceBookEntry> getListOfPBE = [Select id,Product2Id,PriceBook2Id,UnitPrice from PriceBookEntry where PriceBook2Id In:setOfPBIds ];
        
        return getListOfPBE;
        
    }
    
    // Get Map of Product + PriceBook and PriceBookEntry
    public Map<String, PriceBookEntry> getMapOfProAndPBWithPBE(List<PriceBookEntry> listOfPBE){
        
        Map<String, PriceBookEntry> mapOfProAndPBWithPBE = new Map<String, PriceBookEntry>();
        
        for(PriceBookEntry PBE: listOfPBE){
            
            mapOfProAndPBWithPBE.put(PBE.Product2Id + '-' + PBE.Pricebook2Id , PBE);
        }
        
        return mapOfProAndPBWithPBE;
        
    }
    
    
}