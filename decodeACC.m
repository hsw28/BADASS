function [values errors] = decodeACC(timevector, clusters, acc, tdecode, samplingrate, varargin)
% decodes acceleration  based on cell firing. acc. was binned into 14 cm/s2 bins also up to 95% acceleration occupancy (e.g., [-49, −35, −21, −7, 7, 21, 35, 49])
% inputs = %time
            %structure of clusters
            %actual acceleration from accel.m
            %tdecode = bin to decode in seconds. if this is >= .5 seconds there will be 2/tdecode overlap in decoding
            %%time samples per second (hz)

% returns values = [decoded acc, timestamp, bin number, computed probability for being in bin]
%returns errors = errors computed from accerror.m


if length(cell2mat(varargin)) > 0
    binnum = cell2mat(varargin)+1
else
    binnum = 7;
end

t = tdecode;
tsec = t;
t = samplingrate*t;
tdecodesec = tdecode;
tdecode = tdecode*samplingrate;
tm = 1;

mintime = vel(2,1);
maxtime = vel(2,end);


[c indexmin] = (min(abs(timevector-mintime)));
[c indexmax] = (min(abs(timevector-maxtime)));
decodetimevector = timevector(indexmin:indexmax);

%%%%%%%%%%COMMENT THIS OUT IF YOUR DECODED TIME IS DIFFERENT THAN YOUR MAZE TIME%%%%
timevector = decodetimevector;
%%%%%%%%%%%%%%%%%

vel = acc;
assvel = assignvel(decodetimevector, vel);
asstime = assvel(2,:);

%find number of clusters
clustname = (fieldnames(clusters));
numclust = length(clustname)


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
    avg_accel(end+1) = mean(assvel(1,wanted)); % finds average acc within times

end
size(avg_accel);
avg_accel = avg_accel';
%%%





% for each cluster,find the firing rate at esch acc range
j = 1;
fxmatrix = zeros(numclust, length(vbin)+1);
while j <= numclust
    name = char(clustname(j));
    firingdata = clusters.(name);
    fxmatrix(j,:) = firingPerAcc(asstime, assvel, clusters.(name), tsec, vbin, avg_accel);
    dontwant = isnan(fxmatrix(j,:));
    fxmatrix(j,dontwant) = eps;
    j = j+1;
end
fxmatrix



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
              fx = (fxmatrix(c, k));  %should be the rate for cell c at vel k.

              if fx ~= 0
                productme = productme + length(ni)*log(fx);  %IN
              else
                fx = eps;
                productme = productme + length(ni)*log(fx);

              end

               productme = (productme + length(ni)*log(fx));


              expme = (expme) + (fx);
              c = c+1; % goes to next cell, same velocity bin

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
      if tdecodesec>=.5
        tm = tm+(tdecode/2); %overlap
      else
        tm = tm+tdecode;
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
    highestvel = find(vel(1,:)>vbin(end));
    highestvel = median(vel(1,highestvel));
    vnew(bin) = highestvel;
    highestvel
  elseif k==1
    lowestvel = find(vel(1,:)<vbin(1));
    lowestvel = median(vel(1,lowestvel));
    vnew(bin) = lowestvel;
    lowestvel
  else
      vnew(bin) = (vbin(k-1)+vbin(k))/2;

  end
k = k-1;
end


values = [vnew'; times; binnum; perc];

errors = accerror(values, vel,tdecode);
