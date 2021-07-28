function f = decodeACCSHIFT(timevector, clusters, vel, tdecode, maxSHIFT, shift_increment, samplingrate, varagin)
%allows you to shift decoding in time to see most accurate decoding offset
%returns decoding errors per offset
% inputs = %time velvector
            %structure of clusters
            %actual acceleration from accel.m
            %tdecode = bin to decode in seconds. if this is >= .5 seconds there will be 2/tdecode overlap in decoding
            %maximum amount of shift in seconds (for ex, 1 if you maximally want to shift 1 second)
            % amount you would like to shift each run by, in seconds. for ex .01 for 10ms of shift
            %time samples per second.
            %varagin = vector of bins to vin acceleration into. if blank will be [-49, -35, -21, -7, 7, 21, 35, 49];

% returns values = [decoded acc, timestamp, bin number, computed probability for being in bin]
          %errors = errors computed from accerror.m


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
    vals = decodeACC(timevector, firenew, vel, tdecode, samplingrate, varagin);
    [values median mean] = accerror(vals, vel);
    newerrors = [k, median, mean];
    errors(z,:) = newerrors
    z = z+1
    k = k+shift_increment;
end

figure
subplot(2,1,1)
plot(errors(:,1), errors(:,2));
title('medians')
subplot(2,1,2)
plot(errors(:,1), errors(:,3));
title('means')

f = errors;
