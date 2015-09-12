warning off;
clear all;
load('db0.mat', 'GT_MAC');
load('db0.mat', 'GT_OD');
load('db0.mat', 'name');
him = fspecial('gaussian',[5 5],11);
n_resize = 576;
m_resize = 768;
feature_Non_MAC = [];
dir_path = '../diaretdb0_v_1_1/resources/images/diaretdb0_fundus_images/';
for i = 1:130
    
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
    x_mac = GT_MAC(i,2) / 2;
    y_mac = GT_MAC(i,1) / 1.9531;
    
    
    [x_non_mac,y_non_mac] = pixel_not_in_region(x_mac,y_mac);
    
    
    cg1 = imcomplement(gplane);
    
    vess_index = find(vessmac==1);
    cg1(vess_index) = 0;
    cg1 = adapthisteq(cg1);
    
    avg = mean(cg1(:));  %average
    avg_ves = mean(vessmac(:));
    
    for iter = 1 : 5
        tanVal = double(double((x_od-x_non_mac(iter)))/double((y_od-y_non_mac(iter))));
        myAngle = atan(tanVal)*180/pi;
        feature1 = sum(sum(cg1(x_non_mac(iter)-29:x_non_mac(iter)+30, y_non_mac(iter)-29:y_non_mac(iter)+30))) / avg;
        feature2 = mean(mean(cg1(x_non_mac(iter)-29:x_non_mac(iter)+30, y_non_mac(iter)-29:y_non_mac(iter)+30))) - mean(mean(cg1(x_non_mac(iter)-49:x_non_mac(iter)+50, y_non_mac(iter)-49:y_non_mac(iter)+50))) /avg;
        feature3 = sum(sum(vessmac(x_non_mac(iter)-29:x_non_mac(iter)+30,y_non_mac(iter)-29:y_non_mac(iter)+30))) / avg_ves;
        feature4 = myAngle;
        
        feature = [feature1 feature2 feature3 feature4];
        
        feature_Non_MAC = [ feature_Non_MAC ; feature ];
    end
end