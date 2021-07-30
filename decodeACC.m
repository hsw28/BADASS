function [values errors] = decodeAcc(clusters, acc, tdecode, varargin)
% decodes acceleration  based on cell firing. acc. was binned into 14 cm/s2 bins also up to 95% acceleration occupancy (e.g., [-49, −35, −21, −7, 7, 21, 35, 49]) where the two most extreme bins are all values <-49 and >49cm^2/s
% inputs =
            %structure of clusters
            %actual acceleration from accel.m
            %tdecode = bin to decode in seconds. if this is >= 1 seconds there will be 2/tdecode overlap in decoding
            %%time samples per second (hz)
            %varargin = size of bins to bin speed into. if left blank, it will be 14cm^2/s per bin. this will always be symetric around zero
%
% returns values = [decoded acc, timestamp, bin number, computed probability for being in bin]
%returns errors = errors computed from accerror.m
%
%note that if your sampling rate (hz) is not cleaning divisible by your tdecode, your sampling rate will be rounded. For example, if you sample at 30hz and want a tdecode of .25s, this would result in 7.5samples per bin, which will be rounded to 8


if length(cell2mat(varargin)) > 0
    binnum = cell2mat(varargin);
else
    binnum = 14;
end

samplingrate = length(acc)./(max(acc(2,:))-min(acc(2,:)));


t = tdecode;
tsec = t;
t = round(samplingrate*t);
tdecodesec = tdecode;
tdecode = round(tdecode*samplingrate);
tm = 1;

mintime = acc(2,1);
maxtime = acc(2,end);


timevector = acc(2,:);
decodetimevector = timevector;


acc(1,:) = smoothdata(acc(1,:), 'gaussian', 30); %originally had this at 30, trying with 15 now
assacc= assignvel(decodetimevector, acc);
asstime = assacc(2,:);

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
    avg_accel(end+1) = mean(assacc(1,wanted)); % finds average acc within times

end
size(avg_accel);
avg_accel = avg_accel';
%%%

binnedVelo = histcounts(abs(avg_accel), 'BinWidth', binnum);
binnedVelo = binnedVelo./sum(binnedVelo);
k = length(binnedVelo);
percentsum = 0;
while percentsum<.05
  percentsum = percentsum + binnedVelo(k);
  k = k-1;
end
totbin = k+1;
vbin1 = [(-totbin*binnum):binnum:0];
vbin2 = [0:binnum:totbin*binnum];
vbin = [vbin1; vbin2];
vbin = unique(vbin);
vbin = vbin';
fprintf('your accelerations are binned into:')
vbin






% for each cluster,find the firing rate at esch acc range
j = 1;
fxmatrix = zeros(numclust, length(vbin)+1);
while j <= numclust
    name = char(clustname(j));
    firingdata = clusters.(name);
    fxmatrix(j,:) = firingPerAcc(asstime, assacc, clusters.(name), tsec, vbin, avg_accel);
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
      %for the cluster, permute through the acc
      endprob = [];

        for k = (1:length(vbin)+1) %  for the groups of acc
          %PERMUTE THROUGH THE CLUSTERS
          productme =0;
          expme = 0;
          c = 1;

          while c <= numclust
              size(numclust);
              name = char(clustname(c));
              ni = find(clusters.(name)>timevector(tm) & clusters.(name)<timevector(tm+tdecode)); % finds index (number) of spikes in range time
              fx = (fxmatrix(c, k));  %should be the rate for cell c at acc k.

              if fx ~= 0
                productme = productme + length(ni)*log(fx);  %IN
              else
                fx = eps;
                productme = productme + length(ni)*log(fx);

              end

               productme = (productme + length(ni)*log(fx));


              expme = (expme) + (fx);
              c = c+1; % goes to next cell, same acc bin

          end
          % now have all cells at that acc
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


probs = percents;


v = maxprob;

binnum = v;
vnew = zeros(length(v),1);
k=length(vbin)+1;
while k>0
  bin = find(v==k);
  if k==length(vbin)+1
    highestacc = find(acc(1,:)>vbin(end));
    highestacc = median(acc(1,highestacc));
    vnew(bin) = highestacc;
  elseif k==1
    lowestacc = find(acc(1,:)<vbin(1));
    lowestacc = median(acc(1,lowestacc));
    vnew(bin) = lowestacc;
  else
      vnew(bin) = (vbin(k-1)+vbin(k))/2;

  end
k = k-1;
end


values = [vnew'; times; binnum; perc];

errors = accerror(values, acc,tdecodesec);

fprintf('your errors are:')
median_error = nanmedian(errors(1,:))
mean_error = nanmean(errors(1,:))
