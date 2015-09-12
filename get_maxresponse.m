function [ mymax ] = get_maxresponse(temp , r)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

mymax = -1;
d = draw_circle(2*r,r);
%d(:,r-3:r+3) = 0;
d = uint8(d);
%for q = -30:15:30
  %  dr = imrotate(d,q,'crop');
    res = corr2(d(:,:),temp); 
%    if res > mymax
%        mymax = res;
%    end
%end
    mymax = res;
end

