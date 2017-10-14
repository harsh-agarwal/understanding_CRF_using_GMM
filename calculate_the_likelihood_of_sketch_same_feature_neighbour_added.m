%% calculates the likelihood of a particular cnfciguration 
%% for instance given a feature you calculated the you calculated it's likelihood of being a head and at the same time 
%% it's likelohood of having leg as it's neighnour based on the training data that you have seen!  

function [likelihood_matrix_part_wise,likelihood_matrix_pairwise,likelihood_matrix_neighbour]=calculate_the_likelihood_of_sketch_same_feature_neighbour_added(category,lab,segment_into_regions_without_annotations)
    %% the idea is to consider the same approach just to penalise 
    %% this energy function if it destroys the relation between the neighbourhood matrix
    % removing background
    likelihood_matrix_part_wise = zeros(1,2);
    segments_original = unique(segment_into_regions_without_annotations);
    segments_original = segments_original(segments_original~=0);
    individual_part_features = zeros(length(segments_original),5);
    % we try getting the dimensions of a neighbourhood matrix that would
    % define how stable the connectrivity becomes 
    load(sprintf('../part_labellings_for_sketches/%s.mat',category));
    parts_total=parts_total(parts_total~=0);
    size_of_neighbourhood_graph=max(parts_total);
    neighbourhood_graph_now=zeros(size_of_neighbourhood_graph);
    %% calculate the individual features and store them so that for pair wise you just have to concatenate  
    for j=1:length(segments_original)
        % area of the object for relative area measurements
        object_canvas=ones(321,321);
        object_canvas(segment_into_regions_without_annotations==0)=0;
        prop=regionprops(object_canvas,'Area');
        area_of_object=prop.Area;
        %find the regions that has this segment  
        idx=find(segment_into_regions_without_annotations==segments_original(j));    
        % will help us loading the relevant gaussian model 
        part_labelling_segment=unique(lab(idx));
        % part feature calculation 
        part_canvas1=zeros(321,321);
        part_canvas1(idx)=1;
        properties=regionprops(part_canvas1,'Centroid','Area','Perimeter','Orientation','MajorAxisLength','MinorAxisLength',...
                        'Eccentricity');                    
        centroid_of_part=(properties.Centroid)/10;
        relative_area=(area_of_object)/(properties.Area);
        roundedness=(properties.Perimeter)^2/(properties.Area);
        individual_part_features(j,:)=[centroid_of_part(1) centroid_of_part(2) relative_area roundedness segments_original(j)];
        %% load the relevant gaussian model and find a probability and then a likelihood and append that 
        load(sprintf('./Part_feature_gaussian_fits/%s/%d-GMM_model-3.mat',category,part_labelling_segment));
        Y=mvnpdf(individual_part_features(j,1:4),gmm_model.mu,gmm_model.Sigma);
        likelihood_matrix_part_wise=[likelihood_matrix_part_wise;segments_original(j) max(log(Y))]; 
    end
    likelihood_matrix_part_wise=likelihood_matrix_part_wise(2:end,:);
    % number of pairs and what all 
    likelihood_matrix_pairwise=zeros(1,3);
    if(length(segments_original)>1)
        all_two_part_combinations=nchoosek(segments_original,2);
        number_of_combinations_of_two_parts=nchoosek(length(segments_original),2);
        likelihood_matrix_pairwise=zeros(1,3);
        for j=1:number_of_combinations_of_two_parts
            %segment1 what's the original labelling
            segment1=all_two_part_combinations(j,1);
            idx=find(segment_into_regions_without_annotations==segment1);
            part_canvas1=zeros(321,321);
            part_canvas1(idx)=1;
            part_labelling_segment1=unique(lab(idx));
            segment2=all_two_part_combinations(j,2);
            idx=find(segment_into_regions_without_annotations==segment2);
            part_canvas2=zeros(321,321);
            part_canvas2(idx)=1;
            part_labelling_segment2=unique(lab(idx));
            % for instance they both represent head the we don't waant this
            % feature vector
            if(part_labelling_segment1==part_labelling_segment2)
                continue;
            end
            [row1,col1]=find(individual_part_features(:,5)==segment1);
            [row2,col2]=find(individual_part_features(:,5)==segment2);
            base_feature1=individual_part_features(row1,1:4);
            base_feature2=individual_part_features(row2,1:4);
            % once here we know that the two segments represent different parts
            %% let's calculate  the feature vector
            final_pairwise_feature=[base_feature1(1:4) base_feature2(1:4) segment1 segment2];    
            % load the gmm model that has the onformation related to these
            % parts
            if(part_labelling_segment1<part_labelling_segment2)
                a=part_labelling_segment1;
                b=part_labelling_segment2;
            else
                a=part_labelling_segment2;
                b=part_labelling_segment1;
            end
            load(sprintf('./Pairwise_feature_gaussian_fits/%s/%d,%d-GMM_model-3.mat',category,a,b));
            Y=mvnpdf(final_pairwise_feature(1:8),gmm_model.mu,gmm_model.Sigma);
            likelihood_matrix_pairwise=[likelihood_matrix_pairwise;segment1 segment2 max(log(Y))];
            combined=part_canvas1+part_canvas2;
            cc=bwconncomp(combined);
            if(cc.NumObjects==1)
                neighbourhood_graph_now(part_labelling_segment1,part_labelling_segment2)=neighbourhood_graph_now(part_labelling_segment1,part_labelling_segment2)+1;
                neighbourhood_graph_now(part_labelling_segment2,part_labelling_segment1)=neighbourhood_graph_now(part_labelling_segment2,part_labelling_segment1)+1;
            end
        end
        likelihood_matrix_pairwise=likelihood_matrix_pairwise(2:end,:);
    end
    likelihood_matrix_neighbour=zeros(length(segments_original),2);
    % load the avg neighbourhood matrix
    load(sprintf('./mean_neighbourhood_matrices/%s/%s.mat',category,category));
    for j=1:length(segments_original)
        deviation=neighbourhood_graph_now-avg_neighbourhood_matrix;
        deviation=abs(deviation);
        idx=find(segment_into_regions_without_annotations==segments_original(j));
        part_label_of_this_segment=unique(lab(idx));
        likelihood_matrix_neighbour(j,2)=-log(sum(deviation(part_label_of_this_segment,:),2))*10;
    end
    
end



%line 62
        % area of the object for relative area
%         object_canvas=ones(321,321);
%         object_canvas(segment_into_regions_without_annotations==0)=0;
%         prop=regionprops(object_canvas,'Area');
%         area_of_object=prop.Area;
%         
%         %find the regions that has segment 1 
%         idx=find(segment_into_regions_without_annotations==segment1);    
%         part_canvas1=zeros(321,321);
%         part_canvas1(idx)=1;
%         properties1=regionprops(part_canvas1,'Centroid','Area','Perimeter','Orientation','MajorAxisLength','MinorAxisLength',...
%                         'Eccentricity');
%         ellipse_part1_mask=fitting_the_ellipse(properties1);            
%         centroid_of_part=(properties1.Centroid)/10;
%         relative_area=(area_of_object)/(properties1.Area);
%         roundedness=(properties1.Perimeter)^2/(properties1.Area);
%         base_feature1=[centroid_of_part(1) centroid_of_part(2) relative_area roundedness segment1];
%         
%         %find the regions that has segment 2 
%         idx=find(segment_into_regions_without_annotations==segment2);    
%         part_canvas2=zeros(321,321);
%         part_canvas2(idx)=1;
%         properties2=regionprops(part_canvas2,'Centroid','Area','Perimeter','Orientation','MajorAxisLength','MinorAxisLength',...
%                         'Eccentricity');
%         ellipse_part2_mask=fitting_the_ellipse(properties2);            
%         centroid_of_part=(properties2.Centroid)/10;
%         relative_area=(area_of_object)/(properties2.Area);
%         roundedness=(properties2.Perimeter)^2/(properties2.Area);
%         base_feature2=[centroid_of_part(1) centroid_of_part(2) relative_area roundedness segment2];
%         
% %         overlap=ellipse_part1_mask.*ellipse_part2_mask;
% %         overlap_prop=regionprops(overlap,'Area');
% %         if(isempty(overlap_prop)==1)
% %             overlap_area=0;
% %         else
% %             overlap_area=overlap_prop.Area;
% %         end
% %        final_feature=[base_feature1(1:4) double(overlap_area)/double(properties1.Area) base_feature2(1:4) double(overlap_area)/double(properties2.Area)];