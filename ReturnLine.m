function xi = ReturnLine(imgVess);
%input binary vessel image
[x,y] = size(imgVess);

minn = 100000000.000000000;
differ_density = [];
for i = x/5:x-x/5 
    
    % upper region density calculation
    upper_region = imgVess(1:i,:);                      % Upper region 1 to i rows 
    upper_vessel_pixels = find(upper_region == 1);      
    number_of_white_pixels = size(upper_vessel_pixels,1);
    total_upper_pixels = size(upper_region,1) * size(upper_region,2);
    upper_region_density = number_of_white_pixels / total_upper_pixels;
    
    %lower region density calculation
    lower_region = imgVess(i:end,:);        %lower region i to last row 
    lower_vessel_pixels = find(lower_region == 1);
    number_of_white_pixels = size(lower_vessel_pixels,1);
    total_lower_pixels = size(lower_region,1) * size(lower_region,2);
    lower_region_density = number_of_white_pixels / total_lower_pixels;
    
    density_difference = abs(upper_region_density-lower_region_density);
    differ_density = [differ_density ; density_difference];
    if minn > density_difference
        minn = density_difference;
        xi = i;
    end
end
%figure,plot(differ_density);
%imgVess(xi-10:xi+10,:) = 1;
%figure,imshow(imgVess);
end