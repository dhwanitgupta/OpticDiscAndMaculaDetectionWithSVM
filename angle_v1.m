% finding angle using density
function data  = angle(image,vessel,mx,my)

orig = image;
orig = rgb2gray(orig);

prev = -1;  
[a,b] = size(vessel);
orig = imresize(orig,[a,b]);
angle1 = -1;
flag = 0;
startangle = 0;
endangle = 0;
s = orig;
mymin = 10000;
angle1 = -45;
prevs = -1;
prev = 100;

data = [];
mycompare = 0;
for i = -30:30
    im = imrotate(vessel,i);
    [a1,b1] = size(im);
    irad = i/180*pi;
    mx1 = floor(a1/2 - (my-b/2)*sin(irad) - (a/2-mx)*cos(irad));
    my1 = floor((my-b/2)*cos(irad)-(a/2-mx)*sin(irad) + b1/2);
    im(mx1:end, :) = 0;
    r = imrotate(orig,i);
    temp = r;
    r(mx1:end, :) = 0;
    ind = find(r>10);                   
    [N,M] = size(ind);
    ind1 = find(im(:, :)==1);
    [n,m] = size(ind1);
    dup = n*n/N;
    
    im = imrotate(vessel,i);
    im1 = im;
    im(1:mx1, :) = 0;
    r = imrotate(orig,i);
    r(1:mx1, :) = 0;
    ind = find(r>10);
    [N,M] = size(ind);
    
    ind1 = find(im(:, :)==1);
    [n,m] = size(ind1);
    
    ddown = n*n/N;
    
    diff = dup-ddown;
    
%     ind = find(im1(mx1-10:mx1+10,:)==1);   
%     [a2,b2] = size(ind);
%     term = a2;
%     
      mycompare = abs(diff);% - 2*term;
      [i,dup, ddown,mycompare];
%       data(count) = mycompare;
%       count = count+1;
       data = [data mycompare];
%       if mymin>mycompare 
%              mymin = mycompare;
%              angle1 = i;
%              mx2=mx1;
%       end

%     if prevs == -1 & diff>prev
%         angle1 = i;
%         mx2 = mx1;
%         break;
%     end
%     if prev > diff
%         prevs = -1;
%     else
%         prevs = 1;
%     end
%     prev = diff;
 end
%  temp = imrotate(orig,angle1);
%  temp(mx2-10:mx2+10,:) = 255;
%  s = imrotate(temp,-angle1);
% [xmax,imax,xmin,imin] = extrema(data);
% [simin_x,simin_y] = size(imin);
% whitepixs = zeros(1,simin_y);
% for index_imin = 1:simin_y
%       
%      this_angle = imin(index_imin) - 41;
%      rot_img = imrotate(vessel,this_angle);
%      [a1,b1] = size(rot_img);
%      irad = this_angle/180*pi;
%      mx1 = floor(a1/2 - (my-b/2)*sin(irad) - (a/2-mx)*cos(irad));
%      %my1 = floor((my-b/2)*cos(irad)-(a/2-mx)*sin(irad) + b1/2);
%      vessel_at_line = find(rot_img(mx1-5:mx1,:) == 1);
%      [spx,spy] = size(vessel_at_line);
%      whitepixs(index_imin) = spx;
% end
% for t = 1:4
%      [m,ind] = min(whitepixs);
%      whitepixs(ind) = max(whitepixs) + 10;
%      this_angle = imin(ind) - 41;
%      rot_img = imrotate(orig,this_angle);
%      [a1,b1] = size(rot_img);
%      irad = this_angle/180*pi;
%      mx1 = floor(a1/2 - (my-b/2)*sin(irad) - (a/2-mx)*cos(irad));
%      rot_img(mx1-5:mx1+5,:) = 1;
%      imwrite(rot_img,strcat('jan-29-images/op',name,'_',num2str(t),'.jpg'));
% end
end