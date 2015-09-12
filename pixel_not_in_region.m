function [x_non_od,y_non_od] = pixel_not_in_region(x_od,y_od)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
    n_size = 576;
    m_size = 768;
    
    x_od_region = x_od-60:x_od+60;
    y_od_region = y_od-60:y_od+60;
    
    x_non_od = [];
    y_non_od = [];
    
    count = 0;
    
    while count < 5
       
       x_random = randi([61 n_size-61]);
       y_random = randi([61 m_size-61]);
       
       x_index = find(x_od_region == x_random);
       y_index = find(y_od_region == y_random);
       
       if size(x_index,2) == 0 |  size(y_index,2) == 0
           x_non_od = [x_non_od ; x_random];
           y_non_od = [y_non_od ; y_random];
           count = count + 1;
       end
    end
    
end
 


