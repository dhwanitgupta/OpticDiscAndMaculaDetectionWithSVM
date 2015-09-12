him = fspecial('gaussian',[5 5],11);
n_resize = 576;
m_resize = 768;
dir_path = '../diaretdb0_v_1_1/resources/images/diaretdb0_fundus_images/';
total_od_deviation = 0;
true_od = 0;
false_od = 0;
OD = [];
tic
%load('OD_features.mat')
%load('NonOD_features.mat')
features = [feature_OD ; feature_Non_OD];
[features,norm_of_features,minimum_of_features] = scale_features(features);
label = [ ones(60,1) ; zeros(300,1)];
model = svmtrain(label,features , '-s 0  -t 0 -b 1 -c 1000 -q');
for i = 69
    
    display(name{i});
    image_path = strcat(dir_path,name{i});
    rim = imread(image_path);
    t1 = imresize(rim(:,:,1),[n_resize m_resize]);
    t2 = imresize(rim(:,:,2),[n_resize m_resize]);
    t3 = imresize(rim(:,:,3),[n_resize m_resize]);
    rim = uint8(zeros(n_resize , m_resize , 3));
    rim(:,:,1) = t1;
    rim(:,:,2) = t2;
    rim(:,:,3) = t3;
    
    ves_im = rim;
    
    gplane = ves_im(:,:,1)*0.3 + ves_im(:,:,2)*0.6 + ves_im(:,:,3)*0.1 ;
    gplane = imfilter(gplane,him);
    
    vessmac = myVessel(ves_im);
    
    % binarizing the vessels
    binary_vessels = logical(vessmac);
    vessel_pixels = find(vessmac > 0);
    binary_vessels(vessel_pixels) = 1;
    midline = ReturnLine(binary_vessels);
    
    avg = mean(gplane(:));  %average
    avg_ves = mean(vessmac(:));
    
    max_decvalue = -100;
    
    % reducing search space
    cg = histeq(gplane);
    m = max(max(cg));
    newim = cg > m-30;
    
    [labelbw,num] = bwlabel(newim);
    for j = 1:num
        ind = find(labelbw == j);
        [countwhite,q] = size(ind);
        if countwhite < 30
            newim(ind) = 0;
        end
    end
    [row,col] = find(newim == 1);
    
    d_circle = uint8(draw_circle(2*45,45)); % circle
   % display('startin loop');
    
    for x_iterator = 61:n_resize-61
        for y_iterator = 61:m_resize-61
%         x_iterator = row(iterator);
%         y_iterator = col(iterator);
%         if  x_iterator > 61 && x_iterator + 61 < n_resize && y_iterator > 61 && y_iterator + 61 < m_resize
            
            temp_gplane = (gplane( x_iterator - 45 : x_iterator + 45 -1 , y_iterator - 45 : y_iterator + 45 - 1 ));
            temp_big = (gplane( x_iterator - 60 : x_iterator + 60 - 1, y_iterator - 60 : y_iterator + 60 - 1 ));
            
            feature1 = corr2(temp_gplane,d_circle);
            feature2 = (mean(temp_gplane(:)) - mean(temp_big(:)))/avg;
            feature3 = mean(mean(vessmac( x_iterator - 45 : x_iterator + 44 , y_iterator - 45 : y_iterator + 44)))/avg_ves;
            feature4 = double(abs(midline - x_iterator))/n_resize;
            feature5 = entropy(vessmac(:,y_iterator-5:y_iterator+5)) / entropy(vessmac);

            feature = [feature1 feature2 feature3 feature4 feature5] ;
            
            feature =  ( feature - minimum_of_features) ./ norm_of_features; % scaling feature vector
            
            [predicted_label, accuracy, dec_values] = svmpredict([1], feature, model,'-b 1 -q');
            
            if predicted_label == 1
                if max_decvalue < dec_values(1)
                    max_decvalue = dec_values(1);
                    x_od = x_iterator;
                    y_od = y_iterator;
                end
            end
        end
    end
    gplane(x_od-5:x_od +5,y_od-5:y_od+5) = 255;
   % figure,imshow(gplane);
   imwrite(gplane,strcat('results_when_moving_in_whole_img_DB0/',name{i}));
%    cord_od = [ x_od y_od];
%    OD = [ OD ;  cord_od ];
%    actual_xod =  GT_OD(i,2) / 2;
%    actual_yod = GT_OD(i,1) / 1.9531;
%    
%    distance_between_OD = sqrt( double( power( actual_xod - x_od , 2) + power(actual_yod - y_od, 2)) );
%    total_od_deviation = total_od_deviation + distance_between_OD;
%    
%    if distance_between_OD > 40
%        false_od = false_od + 1;
%    else
%        true_od = true_od + 1;
%    end
%    display((true_od / (true_od + false_od)))
end
toc