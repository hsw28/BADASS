function f = decodeAccSHIFT(clusters, acc, tdecode, maxSHIFT, shift_increment, varagin)
%allows you to shift decoding in time to see most accurate decoding offset
%returns decoding errors per offset
% inputs =
            %structure of clusters
            %actual acceleration from accel.m
            %tdecode = bin to decode in seconds. if this is >= .5 seconds there will be 2/tdecode overlap in decoding
            %maximum amount of shift in seconds (for ex, 1 if you maximally want to shift 1 second)
            % amount you would like to shift each run by, in seconds. for ex .01 for 10ms of shift
            %varargin = size of bins to bin speed into. if left blank, it will be 14cm^2/s per bin. this will always be symetric around zero

% returns a matrix listinng decoding shift, medians per shift, and means per shift. also outputs results as a graph


t = tdecode;
clustname = (fieldnames(clusters));
numclust = length(clustname)

errors = zeros(maxSHIFT*2./shift_increment, 3);
k = -maxSHIFT;
z = 1;
while k<=maxSHIFT
  l = 1;
  while l <= numclust %subtract
      name = char(clustname(l));
      firingdata = clusters.(name);
      clustnum = strcat('c', num2str(l));
      firenew.(clustnum) = firingdata+k;
      l = l+1;
  end
    vals = decodeAcc(firenew, acc, tdecode);
    values = accerror(vals, acc, tdecode);
    median = nanmedian(values(1,:));
    mean = nanmean(values(1,:));
    newerrors = [k, median, mean];
    errors(z,:) = newerrors;
    z = z+1;
    k = k+shift_increment;
end

figure
subplot(2,1,1)
plot(errors(:,1), errors(:,2));
title('Shift Vs Median Decoding Error')
xlabel('shift in seconds')
ylabel('median error (cm^2/s)')
subplot(2,1,2)
plot(errors(:,1), errors(:,3));
title('Shift Vs Mean Decoding Error')
xlabel('shift in seconds')
ylabel('mean error (cm^2/s)')

f = errors;
