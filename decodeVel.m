function [values errors probs] = decodeVel(clusters, vel, tdecode, varargin)
  % decodes velocity  based on cell firing. speed was binned into bins of 7cm/s up to 95% speed occupancy (e.g., [0, 7, 14, 21, 28, 35], where the last bin is all speeds >35cm/s
  % inputs =
              %structure of clusters
              %actual acc from velocity.m
              %tdecode = bin to decode in seconds. if this is >= 1 seconds there will be 2/tdecode overlap in decoding
              %varargin = size of bins to bin speed into. if left blank, it will be 7cm/s per bin

  % returns values = [decoded velocity, timestamp, bin number, computed probability for being in bin]
  % returns errors = errors computed from velerror.m
  % returns probs = probability of being in each speed bin per time

  %
  %note that if your sampling rate (hz) is not cleaning divisible by your tdecode, your sampling rate will be rounded. For example, if you sample at 30hz and want a tdecode of .25s, this would result in 7.5samples per bin, which will be rounded to 8



if length(cell2mat(varargin)) > 0
    binnum = cell2mat(varargin);
else
    binnum = 7;
end

samplingrate = length(vel)./(max(vel(2,:))-min(vel(2,:)));


t = tdecode;
tsec = t;
t = round(samplingrate*t);
tdecodesec = tdecode;
tdecode = round(tdecode*samplingrate);
tm = 1;

mintime = vel(2,1);
maxtime = vel(2,end);

timevector = vel(2,:);
decodetimevector = timevector;



vel(1,:) = smoothdata(vel(1,:), 'gaussian', 30);
assvel = assignvel(decodetimevector, vel);
asstime = assvel(2,:);


%find number of clusters
clustname = (fieldnames(clusters));
numclust = length(clustname);


starttime = decodetimevector(1);
endtime = decodetimevector(end);

m = starttime:t:endtime;


duration = endtime-starttime;
 time_v = starttime:tsec:endtime;
 if mod(duration,tsec) ~= 0
     time_v = time_v(1:end-1);
 end
 m = length(time_v);

avg_accel = [];
for i = 1:m
  starttime+tsec*(i-1);
  starttime+tsec*i;
    wanted = find(decodetimevector > starttime+tsec*(i-1) & decodetimevector < (starttime+tsec*i));
    avg_accel(end+1) = mean(assvel(1,wanted)); % finds average vel within times

end
size(avg_accel);
avg_accel = avg_accel';





binnedVelo = histcounts(avg_accel, 'BinWidth', binnum);
binnedVelo = binnedVelo./sum(binnedVelo);
k = length(binnedVelo);
percentsum = 0;
while percentsum<.05
  percentsum = percentsum + binnedVelo(k);
  k = k-1;
end
totbin = k+1;
vbin = [0:binnum:totbin*binnum];
fprintf('your speeds are binned into:')
vbin



% for each cluster,find the firing rate at esch velocity range
j = 1;
fxmatrix = zeros(numclust, length(vbin));
while j <= numclust
    name = char(clustname(j));
    firingdata = clusters.(name);
    fxmatrix(j,:) = firingPerVel(asstime, assvel, clusters.(name), tsec, vbin, avg_accel);
    dontwant = isnan(fxmatrix(j,:));
    fxmatrix(j,dontwant) = eps;
    j = j+1;
end
fxmatrix;




% permute times
  maxprob = [];
  spikenum = 1;
  times = [];
  perc = [];

percents = [];
nivector = zeros((numclust),1);



while tm <= length(timevector)-(rem(length(timevector), tdecode))  & (tm+tdecode) < length(timevector)
      %for the cluster, permute through the velocities
      endprob = [];


        for k = (1:length(vbin)) % six for the 6 groups of velocities
          %PERMUTE THROUGH THE CLUSTERS
          productme =0;
          expme = 0;
          c = 1;

          while c <= numclust
              size(numclust);
              name = char(clustname(c));
              ni = find(clusters.(name)>timevector(tm) & clusters.(name)<timevector(tm+tdecode)); % finds index (number) of spikes in range time
              fx = (fxmatrix(c, k));  %should be the rate for cell c at vel k.

              if fx ~= 0
                productme = productme + length(ni)*log(fx);  %IN
              else
                fx = eps;
                productme = productme + length(ni)*log(fx);

              end


              productme = (productme + length(ni)*log(fx));

              expme = (expme) + (fx);
              c = c+1; % goes to next cell, same velocity

          end
          % now have all cells at that velocity
          tmm = t./samplingrate;

          %IF YOU WANT TO MULTIPLY BY PROB OF LOCATION COMMENT OUT FIRST LINE AND IN SECOND LINE
          endprob(end+1) = (productme) + (-tmm.*expme);

        end


        [val, idx] = (max(endprob));

        nums = isfinite(endprob);
        nums = find(nums == 1);
      endprob = endprob(nums);

          mp = max(endprob(:))-12;

          endprob = exp(endprob-mp);



            conv = 1./sum(endprob(~isnan(endprob)), 'all');

      endprob = endprob*conv;



        percents = vertcat(percents, endprob);

        maxprob(end+1) = idx;
        perc(end+1) = max(endprob);

        times(end+1) = timevector(tm);


        if tdecodesec>=1
          tm = tm+round(tdecode/2); %overlap
        else
          tm = tm+round(tdecode);
        end


end

%length(find(binnedV==4))

%ans = find(binnedV<50);
%[h,p,ci,stats] = ttest2(maxprob, binnedV);
probs = percents;


v = maxprob;

binnumber = v;

k=length(vbin);
while k>0
  bin = find(v==k);
  if k<length(vbin)
    v(bin) = (vbin(k)+vbin(k+1))/2;
  elseif k==length(vbin)
    highestvel = find(vel(1,:)>vbin(end));
    highestvel = median(vel(1,highestvel));
    v(bin) = highestvel;
end
k = k-1;
end


values = [v; times; binnumber; perc];


errors=velerror(values, vel, tdecodesec);

fprintf('your errors are:')
median_error = nanmedian(errors(1,:))
mean_error = nanmean(errors(1,:))
