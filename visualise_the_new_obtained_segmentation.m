%% helps in visualising the segmentation that we have! Nomenclature a bit confusing 

function [rlab]=visualise_the_new_obtained_segmentation(copy_lab)
    copy_lab=copy_lab+1;
    colors=[0,0,0;   % backgorund
        127,219,255;    % sky blue 
        133,20,75;      % maroon type
        255,133,27;     % brownish colour 
        237,247,37;     % yellow
        46,204,64;      % Green
                       
        186,186,173;    % grey
        255,51,255;     % Pink 
        122,82,82;      % Combination of red and gray 
        255,255,255];   % White
        unique(copy_lab);
        R=copy_lab;G=copy_lab;B=copy_lab;
        limit = max(max(R));
        for k=1:limit
            R(R==k) = colors(k,1);
            G(G==k) = colors(k,2);
            B(B==k) = colors(k,3);
        end
        rlab = im2uint16(uint8(cat(3,R,G,B)));
end
    
    
