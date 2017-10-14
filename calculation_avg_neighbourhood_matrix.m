% the script gives us a average neighbourhood graph 
% for instance given a head how likely it is for it to have torso as it's neighbour, or the legs based on the training data 

function calculation_avg_neighbourhood_matrix(category)
    
    if((exist(sprintf('./mean_neighbourhood_matrices/%s',category),'dir'))==0)
       mkdir(sprintf('./mean_neighbourhood_matrices/%s',category));
    end

    %get the list of mirrored and original images 
    fid=fopen(sprintf('../train_val_lists/chosen_train_%s_list.txt',category),'r');
    gt_images=textscan(fid,'%s');
    disp(category);

    %part combination are to be considered and accordingly the features are
    %to be formed by concatenating the individual features together 
    load(sprintf('../part_labellings_training_data/%s.mat',category));
    parts_total = parts_total(parts_total~=0);
    neighbourhood_graph_each=zeros(max(parts_total));
    
    %% For each image we segment it an dtry building upon the neighbourhood graph    
    for i=1:length(gt_images{1,1})
        %load each GT image
        img_name_considered=char(gt_images{1,1}{i,1});
        if(img_name_considered(1)=='n')
            image=imread(sprintf('../GT_core/%s.png',char(gt_images{1,1}{i,1})));
        else
            image=imread(sprintf('../GT_pascal/%s.png',char(gt_images{1,1}{i,1})));
        end
        segmented_image = segmentation_into_regions(image);
        segments_present = unique(segmented_image);
        % background is obvious 
        segments_present = segments_present(segments_present~=0);
        all_two_pair_combination=nchoosek(segments_present,2);
        number_of_two_pair_combination=nchoosek(length(segments_present),2);
        for j=1:number_of_two_pair_combination
            %find_part_1
            part_canvas1 = zeros(321);
            idx = find(segmented_image==all_two_pair_combination(j,1));
            part_canvas1(idx)=1;
            part_labelling_segment1 = unique(image(idx));
            part_canvas2 = zeros(321);
            idx = find(segmented_image==all_two_pair_combination(j,2));
            part_canvas2(idx) = 1;
            part_labelling_segment2 = unique(image(idx));
            if(part_labelling_segment1 == part_labelling_segment2)
                continue;
            end
            combined=part_canvas1+part_canvas2;
            cc=bwconncomp(combined);
            if(cc.NumObjects==1)
                neighbourhood_graph_each(part_labelling_segment1,part_labelling_segment2) = neighbourhood_graph_each...
                    (part_labelling_segment1,part_labelling_segment2)+1;
                neighbourhood_graph_each(part_labelling_segment2,part_labelling_segment1) = neighbourhood_graph_each...
                    (part_labelling_segment2,part_labelling_segment1)+1;
            end
        end
    end
    avg_neighbourhood_matrix=neighbourhood_graph_each/length(gt_images{1,1});
    save(sprintf('./mean_neighbourhood_matrices/%s/%s.mat',category,category),'avg_neighbourhood_matrix');
    end