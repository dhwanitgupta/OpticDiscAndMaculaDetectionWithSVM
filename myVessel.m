function vessel = myVessel(im)

% from the paper Zang 
    S0 = im(:,:,2);
    S0 = uint8(imcomplement(S0));
    
    imgVess = uint8(zeros(size(S0)));
    
    Sopen = uint8(zeros(size(S0,1),size(S0,2),12));
    Sop = uint8(zeros(size(S0)));
    
    
    
    i=1;
    for q = 0:15:165
        stline = strel('line',10,q);
        Sopen(:,:,i) = imopen(S0,stline);
        Sop = max(Sop, Sopen(:,:,i));           %supremum
        i = i+1;
    end
    
  %  Sop = imgVess;
    
   % figure, imshow(Sop);
    Sop = imreconstruct(S0,Sop);            %Resconstruct
   % figure, imshow([S0 Sop Sop1])
    
   Ssum = uint8(zeros(size(S0)));       %sum of top hat
   for i=1:12
        Ssum = Ssum + (Sop - Sopen(:,:,i));
   end
   
   %figure, imshow(Ssum);
   h = fspecial('log',7,7/5);           %log filter
   Slap = imfilter(Ssum,h);
   %figure, imshow(Slap,[]);
   
   
   %final step 
   
   Smax = uint8(zeros(size(S0)));       %morphological opening;
   for q = 0:15:165
       stline = strel('line',20,q);
       Smax = max(Smax, imopen(Slap,stline));           
   end
   S1 = imreconstruct(Slap, Smax);
   
   
   Smin = uint8(zeros(size(S0)));
   for q = 0:15:165
       stline = strel('line',20,q);
       Smin = min(Smax, imclose(S1,stline));           
   end
   S2 = imreconstruct(S1, Smin);
%    
%    figure, imshow(Slap,[]);
%    figure, imshow(S1,[]);
%    figure, imshow(S2,[]);

    Smax = uint8(zeros(size(S0)));
   for q = 0:15:165
       stline = strel('line',25,q);
       Smax = max(Smax, imopen(S2,stline));           %supremum
   end
   Sres = imreconstruct(S2,Smax);
  % figure, imshow(Sres,[]);
    
   bw = Sres>0.8;
   imgt = logical(zeros(size(S0)));                    % some post-processing
   for q = 0:15:165
       stline = strel('line',20,q);
       imgt = imgt | imopen(bw,stline);
   end
      
   
   [L,NUM] = bwlabel(imgt);
   a = [];
   for i=1:NUM
        a = [a size(find(L==i))];
   end
   med = median(a);
   for i=1:NUM
       ind = find(L==i);
       if size(ind,1) < 60
           imgt(ind) = 0;
       end
   end
   
   
   
    vessel = Sres;
end