function to_see_the_interpretation(category)
    img_list=dir(sprintf('../results_test_segmentation/raw_output_part_merged/%s_10000',category));
    for i=13:length(img_list)
        replacement_via_neighbourhood(category,char(img_list(i).name(1:end-4)));
    end