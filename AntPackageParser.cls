public class AntPackageParser {

    public static String RunParser(String xmlString1,String xmlString2) {
       // StaticResource xmlString11 = [select id,body from StaticResource Where Name = 'test1'];
        //StaticResource xmlString22 = [select id,body from StaticResource Where Name = 'test2'];
        //String xmlString1 = xmlString11.body.toString();
        //String xmlString2 = xmlString22.body.toString();
        xmlString1 = xmlString1.replaceAll( '\\s+', '');
        xmlString2 = xmlString2.replaceAll( '\\s+', '');
        List<XMLwrapper> elements_1 = fetchAllElements(xmlString1);
        List<XMLwrapper> elements_2 = fetchAllElements(xmlString2);
        
        system.debug('>>'+elements_1);
        system.debug('>>'+elements_2);
 
        List<XMLwrapper> elementsTotal = mergeLists(elements_1,elements_2);
        
        String resString = XMLWrapperToString(elementsTotal);
		system.debug('merged>>'+elementsTotal);
        return resString;
        
    }
    public static String XMLWrapperToString(List<XMLwrapper> list1){
        String resString='';
        
        String headString = '<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<Package xmlns=\"http://soap.sforce.com/2006/04/metadata\">\n';
        String endString = '\n<version>41.0</version>\n</Package>';
        
        for(XMLwrapper obj : list1){
            String newType = '<types>\n\t<name>'+obj.type+'</name>\n';
            
            for(String member : obj.members){
                newType = newType + '\t<members>'+member+'</members>\n';
            }
            newType = newType + '</types>\n';
        	
            resString = resString + newType;
            
        }
        resString = headString + resString + endString;
        
        return resString;
    }
    
    public static List<XMLwrapper> mergeLists(List<XMLwrapper> list1,List<XMLwrapper> list2){
        List<XMLwrapper> mergedList = new List<XMLwrapper>();
		//Logic here to merge two lists into list1

        Map<String, List<String>> listMap = new Map<String, List<String>>();
        
        for(XMLwrapper listElement: list2){
            if(!listMap.containsKey(listElement.type)){
                listMap.put(listElement.type,listElement.members);
            }
        }
        
        for(XMLwrapper typeObj : list1){
            if(listMap.containsKey(typeObj.type)){
                Set<String> setOfMembers = new Set<String>(typeObj.members);
                setOfMembers.addAll(listMap.get(typeObj.type));
                typeObj.members.clear();
                typeObj.members.addAll(setOfMembers);
                listMap.remove(typeObj.type);
            }
        }
        
        for(String typeObj :listMap.keySet()){
            XMLwrapper newType = new XMLwrapper();
            newType.type = typeObj;
            newType.members = listMap.get(typeObj);
            list1.add(newType);
        }
        
        //Now remove duplicate members from list1 types
        
		       
        return list1;
    }
    
    public static List<XMLwrapper> fetchAllElements(String xmlString) {
        
        boolean hasNext = true;
		List<XMLwrapper> types = new List<XMLwrapper>();
        
        while(hasNext){
            if(xmlString.indexOf('<types>')>-1){
                Integer startPos = xmlString.indexOf('<types>') + 7;
                Integer endPos = xmlString.indexOf('</types>');
                
                //System.debug(xmlString.substring(startPos, endPos));
                
                String typeString = xmlString.substring(startPos, endPos);
                List<String> allMembers = fetchAllMembers(typeString);
				
				XMLwrapper newType = new XMLwrapper();
                newType.type = allMembers.get(allMembers.size()-1);
                allMembers.remove(allMembers.size()-1);
                newType.members = allMembers;
                types.add(newType);
                
                xmlString = xmlString.substring(endPos+8);
            }
            else{
               hasNext = false; 
            }
            
        }
        //system.debug('types'+types);
        return types;
    }
    
	public static List<String> fetchAllMembers(String typeString) {
    	List<String> memberList = new List<String>();
        String attrName;
        //remove <name> node
        if(typeString.indexOf('<name>')>-1){
            attrName = typeString.substring(typeString.indexOf('<name>')+6, typeString.indexOf('</name>'));
            typeString = typeString.substring(0, typeString.indexOf('<name>'))+typeString.substring(typeString.indexOf('</name>')+7);
        }
       	memberList = typeString.split('</members><members>');
        
        for(Integer i=0;i<memberList.size();i++){
            
            if(memberList[i].indexOf('<members>')>-1){
               // system.debug('ifff: '+memberList[i]);
                memberList[i] = memberList[i].substringAfter('<members>');
               // system.debug('now: '+memberList[i]);
            }
            else if (memberList[i].indexOf('</members>')>-1){
               // system.debug('else: '+memberList[i]);
                memberList[i] = memberList[i].substring(0,memberList[i].indexOf('</members>') );
               // system.debug('now: '+memberList[i]);
            }
        }
        
        memberList.add(attrName);
        //system.debug(memberList);
		return memberList;        
    }
    
    
    class XMLwrapper{
        
        String type;
        List<String> members;
        
    }
    
}