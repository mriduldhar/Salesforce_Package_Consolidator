public class XMLReaderController {
    public Blob xmlFileBody1{get;set;}
    public Blob xmlFileBody2{get;set;}
    public boolean readSuccess {get;set;}
    public String xmlDataAsString_1{get;set;}
    public String xmlDataAsString_2{get;set;}
    
    public String resString{get;set;}
    
    
    
    public void readFromFile(){
        try{
            if(xmlFileBody1!=null &&xmlFileBody2!=null )
            {
            	resString='';
            	xmlDataAsString_1 = xmlFileBody1.toString();
            	xmlDataAsString_2 = xmlFileBody2.toString();
                resString = AntPackageParser.RunParser(xmlDataAsString_1,xmlDataAsString_2); 
            }
            else{
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please select both xml files '));
            }
        }catch(Exception e){
            System.debug('Error while parsing xml:'+e);
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Error while parsing one of the above xml files: '+ e));
        }    
        
        	
    }    
    
    public PageReference downloadXML() {
        PageReference newPage =  new PageReference('/apex/MergedPackage');
         newPage.getHeaders().put('content-disposition', 'attachement; filename=Merged_Package_'+Date.today()+'.xml');
        return newPage;
    }
}