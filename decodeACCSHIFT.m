function f = decodeAccSHIFT(clusters, acc, tdecode, maxSHIFT, shift_increment, bins, pos, dim, varargin)
%allows you to shift decoding in time to see most accurate decoding offset
  %returns decoding errors per offset and spearman's rho per offset
% inputs =
            %structure of clusters
            %actual acceleration from accel.m
            %tdecode = bin to decode in seconds. if this is >= .5 seconds there will be 2/tdecode overlap in decoding
            %maximum amount of shift in seconds (for ex, 1 if you maximally want to shift 1 second)
            % amount you would like to shift each run by, in seconds. for ex .01 for 10ms of shift
            %bins = size of bins to bin acc into. we default to 14cm^2/s per bin. this will always be symetric around zero
            %actual positon [#ofpoints, 3] vector, where first column is time, second is x, third is y
            %dim = dimensions to divide positions in, in cm
            % varagin = pixels per cm if inputting position in pixels. if empty no conversion will be made

% returns a matrix listing decoding shift, medians per shift, means per shift, pvalue for spearmans rho and spearmans rho.
%also outputs results as a graph

if rem(maxSHIFT,shift_increment) > 0
  error('your max_SHIFT must be evenly divisable by your shift increment')
end

if length(cell2mat(varargin))>0
  pix_cm = cell2mat(varargin);
  else
  pix_cm = 1;
end

set(0,'DefaultFigureVisible', 'off');


binnum = bins;

t = tdecode;
clustname = (fieldnames(clusters));
numclust = length(clustname);


errors = zeros(round((maxSHIFT*2)./shift_increment), 5);
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
    vals = decodeAcc(firenew, acc, tdecode, binnum);
    values = accerror(vals, acc, tdecode);
    [f pval rho]= spearman_rankresults(pos, acc, vals, dim, pix_cm);
    median = nanmedian(values(1,:));
    mean = nanmean(values(1,:));
    newerrors = [k, median, mean, pval, rho];
    errors(z,:) = newerrors;
    z = z+1;
    k = k+shift_increment;
end

set(0,'DefaultFigureVisible', 'on');
figure
subplot(3,1,1)
plot(errors(:,1), errors(:,2));
title('Shift Vs Median Decoding Error')
xlabel('shift in seconds')
ylabel('median error (cm^2/s)')
subplot(3,1,2)
plot(errors(:,1), errors(:,3));
title('Shift Vs Mean Decoding Error')
xlabel('shift in seconds')
ylabel('mean error (cm^2/s)')
subplot(3,1,3)
plot(errors(:,1), errors(:,5));
title('Shift Vs Spearmans rho (higher is better)')
xlabel('shift in seconds')
ylabel('spearmans rho')


f = errors;
