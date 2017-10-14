function annotating_certain_and_uncertain_segments(category,img_name)
    if((exist(sprintf('./training_for_certainity_and_uncertainity_of_segments'),'dir'))==0)
        mkdir(sprintf('./training_for_certainity_and_uncertainity_of_segments'));
    end
    if((exist(sprintf('./training_for_certainity_and_uncertainity_of_segments/%s',category),'dir'))==0)
        mkdir(sprintf('./training_for_certainity_and_uncertainity_of_segments/%s',category));
    end
    
    %% You have to obtain the segmentation of the image considered and display it as well
    
    %load the matrix that has the output from the net 
    load(sprintf('../results_test_segmentation/raw_output_part_merged/%s_10000/%s.mat',category,img_name));
    %load the image that is converted into RGB form for the output
    %image_orig=imread(sprintf('../results_test_segmentation/processed_image_part_merged/aeroplane_10000/%s.png'...
    %,img_name));
    image_orig=visualise_the_new_obtained_segmentation(lab);
    %imshow(image_orig);
    %imwrite(image_orig,sprintf('./Result_images(before_processing)/%s/%s.png',category,img_name));
    segmented_from_net=segmentation_into_regions(lab);
    count_total_regions=length(unique(segmented_from_net));
    show_segmented_image(lab,segmented_from_net);
%     parts_annotated=unique(lab);
%     parts_annotated_without_bg=parts_annotated(parts_annotated~=0);
%     number_parts_annotated=length(parts_annotated)-1; %cause it includes background so -1
%     count_total_regions=1;
%     %%  Segmenting the sketch into different regions irrespective of parts
%     %   giving every blob a unique number
%     for j=1:number_parts_annotated 
%         idx=find(lab==parts_annotated_without_bg(j)); 
%         part_canvas=zeros(321,321);
%         part_canvas(idx)=1;
%         labelled = bwlabel(part_canvas);
%         number_regions = length(unique(labelled))-1;
%         for m=1:number_regions
%             idx=find(labelled==m);
%             if(isempty(idx)) 
%                 continue;
%             end
%             segmented_from_net(idx)=count_total_regions;
%             count_total_regions=count_total_regions+1;
%         end
%     end
%     %disp(unique(segmented_from_net));
%     figure;
%     imagesc(segmented_from_net);
%     position_of_text=zeros(count_total_regions-1,2);
%     %% calculating the position of the text
%     for n=1:count_total_regions-1
%         idx=find(segmented_from_net==n);
%         if(isempty(idx))
%             continue;
%         end
%         part_canvas=zeros(321,321);
%         part_canvas(idx)=1;
%         properties=regionprops(part_canvas);
%         position_of_text(n,:)= properties.Centroid;
%     end
%     %display the segmented image so that can be used for seeing the certain
%     %and the uncertain segments
%     img_with_parts_shown=insertText(image_orig,position_of_text,1:length(position_of_text),...
%         'AnchorPoint','Center','TextColor','Black','BoxColor','white');
    figure;
    sketch=imread(sprintf('../thickened_original_sketches/%s/%s.png',category,img_name));
    imshow(sketch);
    label=zeros(count_total_regions-1,1);
    x=input('Enter as a vector the segments that are certain!');
    label(x,1)=1;
    %% Calculate probabilty for the original segmentation that we obtain 
    [part_probability_original, pairwise_probability_original,neighbourhood_probability_original]=calculate_the_likelihood_of_sketch_same_feature_neighbour_added(category,lab,segmented_from_net);
    training_matrix=[part_probability_original label];
    save(sprintf('./training_for_certainity_and_uncertainity_of_segments/%s/%s.mat',category,img_name),'training_matrix');
    close all;