function [ features,fnorm ,fmin] =scale_features( features )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
fnorm = [];
fmin = min(features);
for i = 1:size(features,2)
    features(:,i) = features(:,i) - min(features(:,i));
    fnorm = [fnorm ; max(features(:,i)) ];
    features(:,i) = features(:,i) / max(features(:,i));
    
end
fnorm = transpose(fnorm);

end

