
%% would give me the closest fitting ellipse that could fit into a particular part
function [mask] = fitting_the_ellipse(s)
    phi=linspace(0,2*pi,50);
    cosphi=cos(phi);
    sinphi=sin(phi);
    
    for k=1:length(s)
        xbar=s(k).Centroid(1);
        ybar=s(k).Centroid(2);
        
        a=s(k).MajorAxisLength/2;
        b=s(k).MinorAxisLength/2;
        
        theta=pi*s(k).Orientation/180;
        R=[ cos(theta) sin(theta)
            -sin(theta) cos(theta)] ;
        xy=[a*cosphi;b*sinphi];
        xy=R*xy;
        
        x=xy(1,:) + xbar;
        y=xy(2,:) + ybar;
        
        mask=poly2mask(x,y,321,321);
        %imshow(mask);      
    end
end
    
    