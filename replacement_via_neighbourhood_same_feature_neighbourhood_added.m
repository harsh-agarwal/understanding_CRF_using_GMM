function replacement_via_neighbourhood_same_feature_neighbourhood_added(category,img_name,lab_new)
    
%     if((exist(sprintf('./after_post_processing_2'),'dir'))==0)
%         mkdir(sprintf('./after_post_processing_2'));
%     end
    if(exist(sprintf('./output_suggestions_2'),'dir')==0)
        mkdir(sprintf('./output_suggestions_2/%s',(category)));
    end
%     if((exist(sprintf('./Segmented_images_final_2'),'dir'))==0)
%         mkdir(sprintf('./Segmented_images_final_2'));
%     end
%     if((exist(sprintf('./Result_images(before_processing)_2'),'dir'))==0)
%         mkdir(sprintf('./Result_images(before_processing)_2'));
%     end
    if((exist(sprintf('./final_results_replace_svm_training_changed'),'dir'))==0)
        mkdir(sprintf('./final_results_replace_svm_training_changed'));
    end
    
%     if((exist(sprintf('./post_processed_matrices'),'dir'))==0)
%         mkdir(sprintf('./post_processed_matrices'));
%     end
    
%     if((exist(sprintf('./post_processed_matrices/%s',(category)),'dir'))==0)
%         mkdir(sprintf('./post_processed_matrices/%s',(category)));
%     end
    
    if((exist(sprintf('./final_results_replace_svm_training_changed/%s',(category)),'dir'))==0)
        mkdir(sprintf('./final_results_replace_svm_training_changed/%s',(category)));
    end
%     if((exist(sprintf('./after_post_processing_2/%s',(category)),'dir'))==0)
%         mkdir(sprintf('./after_post_processing_2/%s',(category)));
%     end
    if((exist(sprintf('./output_suggestions_2/%s',(category)),'dir'))==0)
        mkdir(sprintf('./output_suggestions_2/%s',(category)));
    end
%     if((exist(sprintf('./Segmented_images_final_2/%s',(category)),'dir'))==0)
%         mkdir(sprintf('./Segmented_images_final_2/%s',(category)));
%     end
%     if((exist(sprintf('./Result_images(before_processing)_2/%s',(category)),'dir'))==0)
%         mkdir(sprintf('./Result_images(before_processing)_2/%s',(category)));
%     end
    % create a text file with the name same as the image and 
    fid=fopen(sprintf('./output_suggestions_2/%s/%s.txt',category,img_name),'w');
    %% You have to obtain the segmentation of the image considered and display it as well
    
    %load the matrix that has the output from the net 
    load(sprintf('../results_test_segmentation/raw_output_part_merged/%s_10000/%s.mat',category,img_name));
    %% get the visualisation of the original image 
    image_orig=visualise_the_new_obtained_segmentation(lab);
    image_orig=insertText(image_orig,[100 280],'Before Post Processing','TextColor','White','BoxColor','Black','FontSize',18);
    lab=lab_new;
    segmented_from_net=segmentation_into_regions(lab);
    %imagesc(segmented_from_net);
%% inserting numbers denoting which region belongs to what segments
%     position_of_text=zeros(count_total_regions-1,2);
%     % calculating the position of the text
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
    %play the segmenteed image 
%     figure;
    %figure;
    %img_with_parts_shown=insertText(image_orig,position_of_text,1:length(position_of_text),...
     %   'AnchorPoint','Center','TextColor','Black','BoxColor','white');
    %imshow(img_with_parts_shown);
%     imwrite(img_with_parts_shown,sprintf('./Segmented_images_final/%s/%s.png',category,img_name));
    
    
    %% Calculate probabilty for the original segmentation that we obtain 
    [part_probability_original, pairwise_probability_original,neighbourhood_probability_original]=calculate_the_likelihood_of_sketch_same_feature_neighbour_added...
        (category,lab,segmented_from_net);
    % load yhe svm model for predicting tyhe uncertain segment
    load(sprintf('svm_models/%s.mat',category));
    %%  Get the neighbourhood matrix 
    adjacency_matrix=neighbourhood_graph(segmented_from_net);
    X=[part_probability_original(:,2),neighbourhood_probability_original(:,2)];
    %% prediction of the uncertain segment 
    certainity_uncertainity_matrix=predict(svm_mdl,X);
    uncertain_segments_index=find(certainity_uncertainity_matrix==0);
    [y,i]=sort(part_probability_original(uncertain_segments_index,2));
    %uncertain_segments=part_probability_original(uncertain_segments_index(1:length(i)),1); 
    uncertain_segments=part_probability_original(uncertain_segments_index(i),1);
    %uncertain_segments=part_probability_original(uncertain_segments_index,1);
    %   treat`each_uncertain_segment_seperately
    segments_present=unique(segmented_from_net);
    %Background is obvious
    segments_present=segments_present(segments_present~=0);
    %calculate the set of certain segments
    certain_segments=setdiff(segments_present,uncertain_segments);
    %for every uncertain segment we are going to give it a thought 
    for i=1:length(uncertain_segments_index)
        fprintf(fid,sprintf('the uncertain segment being considered %d \n',...
            part_probability_original(uncertain_segments(i),1)));
        segment_number_considered=part_probability_original(uncertain_segments(i),1);
        idx_to_be_replaced=find(segmented_from_net==segment_number_considered);
        disp({category,img_name});
        %in the neighbourhood graph see what all segments it is connected to
        segments_connected_to=find(adjacency_matrix(segment_number_considered+1,:)==1);
        segments_connected_to=segments_connected_to(segments_connected_to~=1);
        % we subtract a one cause the adjacency matrix calculation we add oe so BG =1 part1=2....and so on
        segments_connected_to=segments_connected_to-1;
        %% for every uncertain segment we calculate a base energy
        %initialise
        energy=(part_probability_original(uncertain_segments_index(i),2));
        %single part contribution
        for j=1:length(segments_connected_to)
            index_to_test=find(certain_segments==(segments_connected_to(j)));
            if(isempty(index_to_test)==0)
                [row,col]=find(part_probability_original(:,1)==(segments_connected_to(j)));
                %disp(part_probability_original(row,1));
                energy=energy+part_probability_original(row,2);
            end
        end
        %pair wise contribution
        for j=1:length(certain_segments)
            to_find=[certain_segments(j) segment_number_considered];
            comb=ismember(pairwise_probability_original(:,1:2),to_find,'rows');
            if(nnz(comb)==0)
                to_find=[segment_number_considered certain_segments(j)];
                comb=ismember(pairwise_probability_original(:,1:2),to_find,'rows');
                if(nnz(comb)==0)
                    continue;
                end
            end
            position=find(comb==1);
            energy=energy+pairwise_probability_original(position,1);
        end
        neighbourhood_energy=sum(unique(neighbourhood_probability_original(:,2)),1);
        %% we need to find out the labels of the segments it is connected to and of the label as well
        %% Also we need to find out the energy after the replacement
        % the flag is made to see thta if none of the neighbours are
        % certain it is replaced by background
        flag=0;
        candidature_for_replacement=zeros(1,2);
        for j=1:length(segments_connected_to)
            %replacement has to be carried out with a certain segment
            %if idx is empty that just means 
%             idx=find(uncertain_segments_index==segments_connected_to(j));
%             if(isempty(idx)==0)
%                 continue;
%             end
            % once it reaches here that means that it got a certain
            % neighbour
            % find the label of the neighbourhood  
              
            segment_being_replaced_with=segments_connected_to(j);
            fprintf(fid,sprintf('Segment that you are replcing it with %d \n',...
                segment_being_replaced_with));
            % as we got a certain neighbour we don't need to leave it by
            % as it is so as an indicator of that we change flag
            flag=1;
            idx_of_neighbour=find(segmented_from_net==segment_being_replaced_with);
            part_label_of_segment_in_neighbour=unique(lab(idx_of_neighbour));
            copy_lab=lab;
            copy_lab(idx_to_be_replaced)=part_label_of_segment_in_neighbour;
            %the segmentation also changes
            copy_segmented_from_net=segmented_from_net;
            copy_segmented_from_net(idx_to_be_replaced)=segment_being_replaced_with;
            %using the new segmentation and new lab image we calulate
            %various probabilities 
            [part_probability,pairwise_probability,neighbourhood_probability]=calculate_the_likelihood_of_sketch_same_feature_neighbour_added...
                (category,copy_lab,copy_segmented_from_net);
            new_neighbourhood_energy = sum(unique(neighbourhood_probability(:,2)),1);
            %% Calculate  the energy of the new configuration
            new_energy=0;
            % single part contribution
            certain_segments_that_are_neighbours_index=find(ismember(segments_connected_to,certain_segments)==1);
            for l=1:length(certain_segments_that_are_neighbours_index)
                [rows,cols]=find(part_probability(:,1)==segments_connected_to(...
                    certain_segments_that_are_neighbours_index(l)));
                new_energy=new_energy+part_probability(rows,2);
            end
            % pair
            to_be_considered_for_energy_calculation=certain_segments(certain_segments~=segment_being_replaced_with);
            for k=1:length(to_be_considered_for_energy_calculation)
                to_find=[segment_being_replaced_with to_be_considered_for_energy_calculation(k)];
                comb=ismember(pairwise_probability(:,1:2),to_find,'rows');
                if(nnz(comb)==0)
                    to_find=[to_be_considered_for_energy_calculation(k) segment_being_replaced_with];
                    comb=ismember(pairwise_probability(:,1:2),to_find,'rows');
                    if(nnz(comb)==0)
                        continue;
                    end
                end
                position=find(comb==1);
                new_energy=new_energy+pairwise_probability(position,1);
            end
            fprintf(fid,sprintf('the likelihood of the original configuration is %d \n',energy));
            fprintf(fid,sprintf('the likelihood of the new configuration is %d \n',new_energy));
            if((new_energy + new_neighbourhood_energy) > (neighbourhood_energy + energy))
                fprintf(fid,'harsh this seems fine \n');
                %lab(idx_to_be_replaced)=part_label_of_segment_in_neighbour;
                candidature_for_replacement=[candidature_for_replacement; part_label_of_segment_in_neighbour new_energy+new_neighbourhood_energy];
                %energy=new_energy;
                %neighbourhood_energy=new_neighbourhood_energy;
            else
                fprintf(fid,'this is not suggested \n');
            end
        end
        candidature_for_replacement=candidature_for_replacement(2:end,:);
        if(isempty(candidature_for_replacement)==1)
            continue;
        end
        [x,y]=max(candidature_for_replacement(:,2));
        lab(idx_to_be_replaced)=candidature_for_replacement(y,1);
        if(flag==0)
            %commented nothing happening now 
        end
    end
%     segmented_from_net_now=segmentation_into_regions(lab);
%     [part_probability_now, pairwise_probability_now,neighbourhood_probability_now]=calculate_the_likelihood_of_sketch_same_feature_neighbour_added(category,lab,segmented_from_net_now);
%     certainity_uncertainity_matrix=predict(svm_mdl,part_probability_now(:,2));
%     uncertain_segments_index=find(certainity_uncertainity_matrix==0);
    %   treat`each_uncertain_segment_seperately
%     segments_present=unique(segmented_from_net);
%     %Background is obvious
%     segments_present=segments_present(segments_present~=0);
%     %calculate the set of certain segments
%     certain_segments=setdiff(segments_present,uncertain_segments_index);
%     if(isempty(uncertain_segments_index)~=1)
%         replacement_via_neighbourhood_same(category,lab)
%     end
    imnew=visualise_the_new_obtained_segmentation(lab);
    %save(sprintf('./post_processed_matrices/%s/%s.mat',category,img_name),'lab');
    imnew=insertText(imnew,[100 280],'After Post Processing','TextColor','White','BoxColor','Black','FontSize',18);
    sketched_image=imread(sprintf('../thickened_original_sketches/%s/%s.png',category,img_name));
    %sketched_image=insertText(sketched_image,[100 280],'Original Sketch','TextColor','Black','BoxColor','White','FontSize',18);
    %waitforbuttonpress;
    im_legend=prepare_legend(category);
    
    final_image=horzcat((cat(3,sketched_image,sketched_image,sketched_image)),im2uint8(image_orig),im2uint8(imnew),im2uint8(im_legend));
    
    %imshow(final_image);
    title('Original Sketch/ Before Processing/ After Processing');
    imwrite(final_image,sprintf('./final_results_replace_svm_training_changed/%s/%s.png',category,img_name));
      
end
    
    
    