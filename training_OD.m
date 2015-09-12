warning off;
clear all;
close all;
load('db0.mat', 'GT_OD');
load('db0.mat', 'name');
him = fspecial('gaussian',[5 5],11);
n_resize = 576;
m_resize = 768;
feature_OD = [];
dir_path = '../diaretdb0_v_1_1/resources/images/diaretdb0_fundus_images/';
for i = 1:89
    
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
    
    x_od = GT_OD(i,2) / 2;
    y_od = GT_OD(i,1) / 1.9531;
    
    avg = mean(gplane(:));  %average
    avg_ves = mean(vessmac(:));
    if  x_od - 60  > 1 && x_od + 59 < n_resize  && y_od -60 > 1 && y_od + 59 < m_resize
        temp_gplane = (gplane( x_od - 45 : x_od + 45 -1 , y_od - 45 : y_od + 45 - 1 ));
        temp_big = (gplane( x_od - 60 : x_od + 60 - 1, y_od - 60 : y_od + 60 - 1 ));
        
        feature1 = get_maxresponse(temp_gplane,45);
        feature2 = (mean(temp_gplane(:)) - mean(temp_big(:)))/avg;
        feature3 = mean(mean(vessmac( x_od - 45 : x_od + 44 , y_od - 45 : y_od + 44)))/avg_ves;
        feature4 = double(abs(midline - x_od))/n_resize;
        feature5 = entropy(vessmac(:,y_od-5:y_od+5)) / entropy(vessmac);
        feature = [feature1 feature2 feature3 feature4 feature5];
        
        feature_OD = [ feature_OD ; feature ];
    end
end