him = fspecial('gaussian',[5 5],11);
n_resize = 576;
m_resize = 768;
dir_path = '../diaretdb1_v_1_1/resources/images/ddb1_fundusimages/';
total_mac_deviation = 0;
true_mac = 0;
false_mac = 0;
MAC = [];
tic
load('db0.mat', 'GT_MAC');
load('OD.mat')
load('NonMAC_features.mat');
load('MAC_features.mat');
features = [feature_MAC(1:60,:) ; feature_Non_MAC(130:455,:)];
[features,norm_of_features,minimum_of_features] = scale_features(features);
label = [ ones(60,1) ; zeros(326,1)];
model = svmtrain(label,features , '-s 0  -t 2 -b 1 -c 1000 -q');

for i = 61:130
    
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
    
    x_od = OD(i-60,1);
    y_od = OD(i-60,2);
    [data] = angle_v1(rim,vessmac,x_od,y_od);
    [zmax,imax,zmin,imin]= extrema(data);
    imin = imin-31;
    
    max_decvalue = -100;
    for x_iter = n_resize/10 : 9*n_resize/10
        for y_iter = 120 : m_resize -120
            tanVal = (x_od-x_iter)/(y_od-y_iter);
            myAngle = atan(tanVal)*180/pi;
            if min(abs(imin - myAngle)) < 5
                feature1 = sum(sum(cg1(x_iter-29:x_iter+30, y_iter-29:y_iter+30))) / avg;
                feature2 = mean(mean(cg1(x_iter-29:x_iter+30, y_iter-29:y_iter+30))) - mean(mean(cg1(x_iter-49:x_iter+50, y_iter-49:y_iter+50))) /avg;
                feature3 = sum(sum(vessmac(x_iter-29:x_iter+30,y_iter-29:y_iter+30))) / avg_ves;
                feature4 = myAngle;
                
                feature = [feature1 feature2 feature3 feature4];
                feature =  ( feature - minimum_of_features) ./ norm_of_features; % scaling feature vector
                
                [predicted_label, accuracy, dec_values] = svmpredict([1], feature, model,'-b 1 -q');
                if predicted_label == 1 && dec_values(1) > max_decvalue
                    max_decvalue = dec_values(1);
                    x_mac = x_iter;
                    y_mac = y_iter;
                end
            end
        end
    end
    gplane(x_od-5:x_od+5,y_od-5:y_od+5) = 0;
    gplane(x_mac-5:x_mac+5,y_mac-5:y_mac+5) = 255;
    imwrite(gplane,strcat('result_mac/',name{i}));
    
    cord_mac = [ x_mac y_mac];
    MAC = [ MAC ;  cord_mac ];
    actual_xmac =  GT_MAC(i,2) / 2;
    actual_ymac = GT_MAC(i,1) / 1.9531;
    
    distance_between_MAC = sqrt( double( power( actual_xmac - x_mac , 2) + power(actual_ymac - y_mac, 2)) );
    total_mac_deviation = total_mac_deviation + distance_between_MAC;
    
    if distance_between_MAC > 25
        false_mac = false_mac + 1;
    else
        true_mac = true_mac + 1;
    end
    display((true_mac / (true_mac + false_mac)))
end