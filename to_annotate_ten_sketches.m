%% got some data for the SVM 

function to_annotate_ten_sketches(category)
    img_list=dir(sprintf('../results_test_segmentation/raw_output_part_merged/%s_10000',category));
    for i=3:12
        load(sprintf('./training_for_certainity_and_uncertainity_of_segments/%s/%s.mat',category,char(img_list(i).name(1:end-4))));
        load(sprintf('../results_test_segmentation/raw_output_part_merged/%s_10000/%s.mat',category,char(img_list(i).name(1:end-4))));
        segmented_from_net=segmentation_into_regions(lab);
        [part_probability,pairwise_probability,neighbourhood_probability]=calculate_the_likelihood_of_sketch_same_feature_neighbour_added(category,lab,segmented_from_net);
        training_matrix(:,2)=part_probability(:,2);
        training_matrix=[training_matrix,neighbourhood_probability(:,2)];
        save(sprintf('./training_for_certainity_and_uncertainity_of_segments/%s/%s.mat',category,char(img_list(i).name(1:end-4))),'training_matrix');
        %annotating_certain_and_uncertain_segments(category,char(img_list(i).name(1:end-4)));
        %waitforbuttonpress;
    end