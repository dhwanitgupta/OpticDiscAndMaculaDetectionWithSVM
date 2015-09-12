function [BP,imgt]  = vesdetect_v1(gplane)
        
        gplane = adapthisteq(gplane);
        kernel = uint8(zeros(15,15));
        kernel(8,8) = 1;
        
        [r,c] = size(gplane);
        m = mymatch();
       
       %gplane = imresize(gplane,size(bw));
         con = conv2(gplane,m,'same');
         con = uint8(con);
        gplane = uint8(conv2(gplane,kernel,'same'));
       % mask = get_mask(gplane);
        bw = logical(zeros(size(gplane)));
        %ind_mask = find(mask == 1);
        [r c] = size(bw);
       
        %bw(ind_mask) = 0;
       
        %imshow(bw);
        
        %figure,subplot(1,2,1),imshow(con);
         inten_max = max(max(gplane));
         indexs = find(gplane > inten_max - 100);
         con(indexs) = 0;
%         %subplot(1,2,2),imshow(con);
%         %size(indexs)
       % bw = logical(zeros(r,c));
         ind = find(con > 10);
         bw(ind) = 1;
         %bw(ind_mask) = 0;
        [limg,num] = bwlabel(bw);
        BP  = bw;
        %imshow(bw);
        for z = 1:num
            ind = find(limg == z);
            [x,y] = size(ind);
            if x < 50
                bw(ind) = 0;
            end
        end
    %    bw = bw - mask;
         %figure,imshow(bw);
         temp_back = bw;
         imgVess = logical(zeros(size(bw)));
         for q = 0:15:165
             stline = strel('line',10,q);
             imgVess = imgVess | imopen(bw,stline);
         end
         bw = imgVess;
         imgVess(:,:) = 0;
         for q = 0:15:165
             stline = strel('line',20,q);
             imgVess = imgVess | imopen(bw,stline);
         end
         bw = imgVess;
         sd = strel('disk',2);
         imgVess = imopen(bw,sd);
      %   imgVess = imclose(imgVess,sd);
         bw = imgVess;
         imgVess(:,:) = 0;
         imgt = imgVess;
         for q = 0:15:165
             stline = strel('line',25,q);
             imgVess = imgVess | imopen(bw,stline);
         end
         %figure,imshow(imgVess);
         for q = 0:15:165
             stline = strel('line',20,q);
             imgt = imgt | imopen(bw,stline);
         end
         %imshow(imgt);
          
    %    figure(i),subplot(1,2,1),imshow(im);
     %   subplot(1,2,2),imshow(bw);
end