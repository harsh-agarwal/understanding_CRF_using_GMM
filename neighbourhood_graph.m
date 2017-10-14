 %% this script is going to give you the adjacenc graph 
 %% given a segmentation it would tell you what parts are neighbours and what are not 

    function [adjacency_matrix]=neighbourhood_graph(segmented_from_net)
%         load(sprintf('../results_test_segmentation/raw_output_part_merged/%s_10000/%s.mat',category,img_name));
%         img=imread(sprintf('../results_test_segmentation/processed_image_part_merged/%s_10000/%s.png',category,img_name));
%         %lab=lab-ones(321,321);
%         segmented_from_net=lab;
%         parts_annotated=unique(segmented_from_net);
%         parts_annotated_without_bg=parts_annotated(parts_annotated~=0);
%         number_parts_annotated=length(parts_annotated)-1; %cause it includes background so -1
%         count_total_regions=1;
%         %%
%         
%         %Segmenting the sketch into different regions irrespective of parts
%         for j=1:number_parts_annotated 
%             idx=find(lab==parts_annotated_without_bg(j));
%             part_canvas=zeros(321,321);
%             part_canvas(idx)=1;
%             labelled = bwlabel(part_canvas);
%             number_regions = length(unique(labelled))-1;
%             for m=1:number_regions
%                 idx=find(labelled==m);
%                 if(isempty(idx))
%                     disp(m);
%                     continue;
%                 end
%                 segmented_from_net(idx)=count_total_regions;
%                 count_total_regions=count_total_regions+1;
%             end
%         end
%         %we obtain the segmented image now :)
%         position_of_text=zeros(count_total_regions-1,2);
%         for n=1:count_total_regions-1
%             idx=find(segmented_from_net==n);
%             if(isempty(idx))
%                 continue;
%             end
%             part_canvas=zeros(321,321);
%             part_canvas(idx)=1;
%             properties=regionprops(part_canvas);
%             position_of_text(n,:)= properties.Centroid;
%         end
%         img_with_parts_shown=insertText(img,position_of_text,(2:length(position_of_text)+1),'AnchorPoint','Center','TextColor','Black','BoxColor','white');
%         imshow(img_with_parts_shown);
        
        segmented_from_net_for_graph=segmented_from_net + ones(321,321);
        count_total_regions = length(unique(segmented_from_net_for_graph));
        adjacency_matrix=zeros(count_total_regions);
        for j=1:count_total_regions
            for k=1:count_total_regions
                if(j==k)
                    continue;
                end
                part_canvas_1=zeros(321,321);
                idx=find(segmented_from_net_for_graph==j);
                part_canvas_1(idx)=1;
                part_canvas_2=zeros(321,321);
                idx=find(segmented_from_net_for_graph==k);
                part_canvas_2(idx)=1;
                final_part_canvas=part_canvas_1+part_canvas_2;
                CC=bwconncomp(final_part_canvas);
                if(CC.NumObjects==1)
                    adjacency_matrix(j,k)=1;
                end
            end
        end
        
                
    end
        