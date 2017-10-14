% we had trained an SVM model that would help us in categorising if given a part_probability whether it is 
% cetain or incertain wbout the prediction! 

function [uncertain_segments_index]=calculate_uncertain_segments(category,part_probability)
    load(sprintf('svm_models/%s.mat',category));
    certainity_uncertainity_matrix=predict(svm_mdl,part_probability(:,2));
    uncertain_segments_index=find(certainity_uncertainity_matrix==0);