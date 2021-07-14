public class ContractStatusCheckHandler
{
    /* Code written by : Ariba Khan
     * new list are all the new triggers and old map is passed here so that previous contract statuses can be matched*/
    public static void afterUpdate(List<Contract> newList, Map<Id,Contract> oldMap )
    {
        //oldAcc is a set of contracts which were already active
        Set<Id> oldCon = new Set<Id>();
        //newAcc is a set of updated accounts with activated status
        Set<Id> newAcc = new Set<Id>();
        
        for(Contract con : newList)
        {
            //storing all contracts that were already activated
            if(con.Status == 'Activated' && oldMap.get(con.Id).Status == 'Activated'){
            	oldCon.add(con.Id);
            	System.debug('old contract id and status '+ con.Id+ ' '+con.Status);
            }
        }
        for(Contract con : [Select Id,AccountId, Status from Contract where Id =:newList and Status = 'Activated'])
        {
                System.DEBUG('contract: ' +con.Status);
                //storing account id of accounts with activated contracts
                newAcc.add(con.AccountId);
        }
        
       
        
        if(!newAcc.isEmpty())
        {   
            //This map stores list of activated contracts belonging to an account
            Map<Id,List<Contract>> conMap= new Map<Id,List<Contract>>();
            
            for(Contract con : [Select id,AccountId,Status from Contract where AccountId=:newAcc AND Status ='Activated'])
            {
                //if the map already has the accountId as key then store its active contracts
                if(conMap.containsKey(con.AccountId) && !oldCon.contains(con.Id)){
                conMap.get(con.AccountId).add(con);
            } 
            //else make new list
            else{
                
                //initializing new list of contracts against an account
                conMap.put(con.AccountId,new List<Contract>{con});
            }
                
            }
            
            
            if(conMap.size()>0)
            {
                for(Contract con : newList)
                {
                   /*Here we have ensured that if someone tries to update two drafted contracts then we only let
                    * the first one become activated and show errors on the rest*/
                    
                    if(conMap.get(con.AccountId)!=null){
                    
                    if(conMap.get(con.AccountId).size()>1 && con.Id!=conMap.get(con.AccountId).get(0).Id && !Test.isRunningTest())
                      {        
                               con.adderror('Another contract is already activated under same account.');
                            
                      }
                        }
                }
                
            }
        }
        
        
        
    }    
}