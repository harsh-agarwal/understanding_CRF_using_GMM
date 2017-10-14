% helps you in defining which parts to annotate and by what! 

function mapping = Cls2Part(ClasName)

switch ClasName,
        case 'aeroplane'
            %mapping.Parts = {'body', 'wing', 'tail', 'engine', 'wheel'};
	    mapping.Parts = {'body', 'wheels', 'tail', 'engine', 'wings'};
           
        case 'bottle' 
            mapping.Parts = {'body'};
            
        case 'cat'
            mapping.Parts = {'head',  'body', 'leg', 'tail'}; 
            
        case 'chair'
            mapping.Parts = {'body'};
            
        case 'diningtable'
            mapping.Parts = {'body'};         
            
        case 'dog'
            mapping.Parts = {'head', 'body', 'leg', 'tail'};
           
        case 'cow'
            mapping.Parts = {'head',  'body', 'leg', 'tail'}; 
       
        case 'sheep'
            mapping.Parts = {'head', 'body',  'leg', 'tail'}; 
   
        case 'horse' 
            mapping.Parts = {'head',  'body', 'leg', 'tail'}; 
               
        case 'person' 
            mapping.Parts = {'head', 'body',  'arm', 'leg'}; 
            
        case 'pottedplant'
            mapping.Parts = {'pot','plant'};  

        case 'bird'

            mapping.Parts = {'body','dont care','tail','dont care','dont care','head','leg','wing'};
            
        case 'bicycle'

            mapping.Parts = {'wheel','saddle','handlebar','body'}; 
        case 'bus'

                mapping.Parts = {'body','mirror','window','wheel','headlight','door'};

        case 'car'

                mapping.Parts = {'body','mirror','window','wheel','headlight','door'};

        case 'motorbike'

                mapping.Parts = {'wheel','saddle','handlebar','body'};
        case 'train'
            mapping.Parts = {'body','dont care','dont care','dont care','headlight'};
            
        case 'tvmonitor'
            mapping.Parts = {'screen'};
            
        case 'sofa'
            mapping.Parts = {};
        
        case 'boat'
            mapping.Parts = {};
        
end
    
