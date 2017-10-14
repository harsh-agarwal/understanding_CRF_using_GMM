%% the function to call to final post process 

function post_process(category)
    %create an image list
    img_list = dir(sprintf('../results_test_segmentation/raw_output_part_merged/%s_10000',category));
    %in a for loop take ech and every image and load the following
    %corresponding file
    disp(category);
    for i=13:length(img_list)
        load(sprintf('../results_test_segmentation/raw_output_part_merged/%s_10000/%s.mat',category,char(img_list(i).name(1:end-4))));
        %replacement_via_neighbourhood_all_replace(category,char(img_list(i).name(1:end-4)),lab);
        replacement_via_neighbourhood_same_feature_neighbourhood_added(category,char(img_list(i).name(1:end-4)),lab);
        
    end
    %load(sprintf('../results_test_segmentation/raw_output_part_merged/%s_10000/%s.mat',category,img_name));
    %this would create a variable named as lab in the workspace so use it
    %as an arguement for replacement_via_neighbourhood
end