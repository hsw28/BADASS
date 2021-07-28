function f = decodeVelSHIFT(timevector, clusters, vel, tdecode, maxSHIFT, shift_increment, samplingrate, varagin)
  %allows you to shift decoding in time to see most accurate decoding offset
  %returns decoding errors per offset
  % inputs = %time
              %structure of clusters
              %actual acc from velocity.m
              %tdecode = bin to decode in seconds. if this is >= .5 seconds there will be 2/tdecode overlap in decoding
              %maximum amount of shift in seconds (for ex, 1 if you maximally want to shift 1 second)
              % amount you would like to shift each run by, in seconds. for ex .01 for 10ms of shift
              %time samples per second.
              %varagin = vector of bins to vin acceleration into. if blank will be  [0, 7, 14, 21, 28, 35];

  % returns values = [decoded velocity, timestamp, bin number, computed probability for being in bin]
            %errors = errors computed from velerror.m


clustname = (fieldnames(clusters));
numclust = length(clustname)

t = tdecode;
errors = zeros(ceil(maxSHIFT*2./shift_increment)+1, 3);
k = -maxSHIFT;
z = 1;

while k<=maxSHIFT+shift_increment
  l = 1;
  while l <= numclust %subtract
      name = char(clustname(l));
      firingdata = clusters.(name);
      clustnum = strcat('c', num2str(l));
      firenew.(clustnum) = firingdata+k;
      l = l+1;
  end
    [vals probs vbin] = decodeVel(timevector, firenew, vel, tdecode, t);

    %THIS IS TO GET ERROR "LENGTH"
    [values median mean] = velerror(vals, vel);
    newerrors = [k, median, mean];
    errors(z,:) = newerrors

    %%%%this is to get accuracy
    %realbin = binVel(timevector, vel, tdecode, vbin);
    %realval = realbin(1,:);
    %wanted = find(realval>1);
    %realval(wanted) = 2;
    %decval = vals(3,:);
    %wanted = find(decval>1);
    %decval(wanted) = 2;
    %con = confusionmat(decval, realval)
    %zerosens = con(1,1)./length(find(realval==1));
    %movesens = con(2,2)./length(find(realval==2));
    %newerrors = [k,accur, zerosens];
    %totalcorrect = (con(1,1)+con(2,2))./length(find(realval>0));
    %newerrors = [k, zerosens, movesens, totalcorrect];
    %errors(z,:) = newerrors

    z = z+1
    k = k+shift_increment;
end

figure
subplot(2,1,1)
plot(errors(:,1), errors(:,2));
title('medians')
title('accuracy')
subplot(2,1,2)
plot(errors(:,1), errors(:,3));
title('means')
title('sensitivity to zero velocity')

f = errors;
