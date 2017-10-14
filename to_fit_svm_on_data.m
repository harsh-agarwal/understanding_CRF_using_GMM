%% training the SVM 

function to_fit_svm_on_data(category)
    if((exist(sprintf('./svm_models'),'dir'))==0)
        mkdir(sprintf('./svm_models'));
    end
    if((exist(sprintf('./svm_models/%s',category),'dir'))==0)
        mkdir(sprintf('./svm_models/%s',category));
    end
    img_list=dir(sprintf('./training_for_certainity_and_uncertainity_of_segments/%s',category));
    X=[0 0];
    Y=[0];
    for i=3:length(img_list)
        load(sprintf('./training_for_certainity_and_uncertainity_of_segments/%s/%s.mat',category,char(img_list(i).name(1:end-4))));
        X1=training_matrix(:,2);
        X2=training_matrix(:,4);
        Y1=training_matrix(:,3);
        X=[X;X1 X2];
        Y=[Y;Y1];
    end
    X=X(2:end,:);
    Y=Y(2:end,:);
    svm_mdl=fitcsvm(X,Y);
    save(sprintf('./svm_models/%s.mat',category),'svm_mdl');
end