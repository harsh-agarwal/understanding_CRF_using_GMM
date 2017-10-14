function [img_legend]=prepare_legend(category)
    load(sprintf('../part_labellings_for_sketches/%s',category));
    parts_total=parts_total(parts_total~=0);
    %parts_total=0:4;
    colors=[50,50,50;   % backgorund
        127,219,255;    % sky blue 
        133,20,75;      % maroon type
        255,133,27;     % brownish colour 
        237,247,37;     % yellow
        46,204,64;      % Green                
        186,186,173;    % grey
        255,51,255;     % Pink 
        122,82,82;      % Combination of red and gray 
        255,255,255];   % White
    number_of_colors_to_mention=length(parts_total);
    img_legend=ones(321,321,3);
    img_legend=im2uint8(img_legend);
    origin=[0 0];
    width=30;
    b=5;
    part_names=Cls2Part(sprintf('%s',category));
    for i=1:length(parts_total)
        img_legend=insertShape(img_legend,'FilledRectangle',[origin(1) (i)*width+origin(2)+b width width],'Color',[colors(i+1,:)],'Opacity',1);
        img_legend=insertText(img_legend,[width+10*b (i)*width+origin(2)+b],part_names.Parts(parts_total(i)),'BoxOpacity',1,'BoxColor','Black','TextColor','White','FontSize',18);
    end
    %imshow(img_legend);
end