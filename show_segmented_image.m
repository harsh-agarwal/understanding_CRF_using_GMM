%5 a head can have two blobs a code to visualise the segmented image 

function show_segmented_image(lab,segmented)    
    image_orig=visualise_the_new_obtained_segmentation(lab);    
    count_total_regions=length(unique(segmented));
    segment_number_present=unique(segmented);
    segment_number_present=segment_number_present(segment_number_present~=0);
    position_of_text=zeros(count_total_regions-1,2);
    % calculating the position of the text
    for n=1:count_total_regions-1
        idx=find(segmented==n);
        if(isempty(idx))
            continue;
        end
        part_canvas=zeros(321,321);
        part_canvas(idx)=1;
        properties=regionprops(part_canvas);
        position_of_text(n,:)= properties.Centroid;
    end
    %play the segmenteed image 
    figure;
    img_with_parts_shown=insertText(image_orig,position_of_text,segment_number_present,...
       'AnchorPoint','Center','TextColor','Black','BoxColor','white');
    imshow(img_with_parts_shown);
