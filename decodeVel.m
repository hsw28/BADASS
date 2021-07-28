function [values errors] = decodeVel(timevector, clusters, vel, tdecode, samplingrate, varagin)
  % decodes velocity  based on cell firing.
  % inputs = %time
              %structure of clusters
              %actual acc from velocity.m
              %tdecode = bin to decode in seconds. if this is >= .5 seconds there will be 2/tdecode overlap in decoding
              %maximum amount of shift in seconds (for ex, 1 if you maximally want to shift 1 second)
              % amount you would like to shift each run by, in seconds. for ex .01 for 10ms of shift 
              %time samples per second.
              %varagin = vector of bins to bin velocity into. if blank will be  [0, 7, 14, 21, 28, 35];

  % returns values = [decoded velocity, timestamp, bin number, computed probability for being in bin]
            %errors = errors computed from velerror.m

if length(varargin{1}) > 0
      vbin = cell2mat(varargin)
else
      vbin = [0, 7, 14, 21, 28, 35];
end


tic
t = tdecode;
tsec = t;
t = 2000*t;
tdecodesec = tdecode;
tdecode = tdecode*2000;
tm = 1;

mintime = vel(2,1);
maxtime = vel(2,end);

[c indexmin] = (min(abs(timevector-mintime))); %how close the REM time is to velocity-- index is for REM time
[c indexmax] = (min(abs(timevector-maxtime))); %how close the REM time is to velocity
decodetimevector = timevector(indexmin:indexmax); %time vector is the REM time
if length(decodetimevector)<3 %this means vel didnt overlap with REM and its REM
  decodetimevector = [mintime:1/2000:maxtime];
else
  timevector = decodetimevector;
end

vel(1,:) = smoothdata(vel(1,:), 'gaussian', 30); %originally had this at 30, trying with 15 now
assvel = assignvel(decodetimevector, vel);
asstime = assvel(2,:);


%find number of clusters
clustname = (fieldnames(clusters));
numclust = length(clustname);



%%%NEW
starttime = decodetimevector(1);
endtime = decodetimevector(end);

m = starttime:t:endtime;


duration = endtime-starttime;
 time_v = starttime:tsec:endtime;
 if mod(duration,tsec) ~= 0
     time_v = time_v(1:end-1);
 end
 m = length(time_v);
%avg_accel = zeros(m,1);
avg_accel = [];
for i = 1:m
  starttime+tsec*(i-1);
  starttime+tsec*i;
    wanted = find(decodetimevector > starttime+tsec*(i-1) & decodetimevector < (starttime+tsec*i));
    avg_accel(end+1) = mean(assvel(1,wanted)); % finds average vel within times

end
size(avg_accel);
avg_accel = avg_accel';




vbin;




% for each cluster,find the firing rate at esch velocity range
j = 1;
fxmatrix = zeros(numclust, length(vbin));
while j <= numclust
    name = char(clustname(j));
    firingdata = clusters.(name);
    currclust = clusters.(name);



    fxmatrix(j,:) = firingPerVel(asstime, assvel, clusters.(name), tsec, vbin, avg_accel);

    dontwant = isnan(fxmatrix(j,:));
    fxmatrix(j,dontwant) = eps;

    intime = find(currclust>=(decodetimevector(1)) & currclust<=decodetimevector(end));
    clusters.(name) = currclust(intime);

    if tdecodesec>=.5 %FOR TRAIN
        [clusttrain edges] = histcounts(clusters.(name), [decodetimevector(1):.5:decodetimevector(end)]); %FOR TRAIN
        train.(name) = clusttrain; %FOR TRAIN
        train.(name) = smoothdata(clusttrain,'gaussian', 3); %3 is 1.5 seconds for a 1 second window

    else
        clusttrain = histcounts(clusters.(name), [decodetimevector(1):.5:decodetimevector(end)]); %FOR TRAIN
        train.(name) = smoothdata(clusttrain,'gaussian', 3); %3 is 1.5 seconds for a 1 second window

    end
    %fxmatrix(j,:) = smoothdata(fxmatrix(j,:), 'gausswin')

    j = j+1;
end



fxmatrix;


 %find prob the animal is each velocity DONT NEED BUT CAN BE USEFUL

%probatvelocity = zeros(length(vbin),1);
%binnedV = binVel(asstime, vel, t/2000, vbin);
%legitV = find(binnedV<100);
%for k = 1:length(vbin)
%    numvel = find(binnedV == (k));
%    probatvelocity(k) = length(numvel)./length(legitV);
%end
%probatvelocity;



% permue times
  maxprob = [];
  spikenum = 1;
  times = [];
  perc = [];

%percents = zeros(length(timevector)-(rem(length(timevector), t)), length(vbin)) ;
percents = [];
nivector = zeros((numclust),1);

trainnum = 1;


timevector = [timevector(1):1/2000:timevector(end)]; %FOR TRAIN
while tm <= length(timevector)-(rem(length(timevector), tdecode)) & (tm+tdecode) < length(timevector)
      %for the cluster, permute through the velocities
      endprob = [];


        for k = (1:length(vbin)) % six for the 6 groups of velocities
          %PERMUTE THROUGH THE CLUSTERS
          %productme = 1; OLD
          productme =0;
          expme = 0;
          c = 1;

          while c <= numclust

              name = char(clustname(c));
              %ni = length(find(clusters.(name)>timevector(tm) & clusters.(name)<=timevector(tm+tdecode))); % finds index (number) of spikes in range time


              curtrain = train.(name); %FOR TRAIN
              ni = (curtrain(trainnum)+curtrain(trainnum+1)); %FOR TRAIN




              fx = (fxmatrix(c, k));  %should be the rate for cell c at vel k.


              productme = (productme + (ni)*log(fx));

              %productme = productme + log((fx^length(ni)));

              expme = (expme) + (fx);
              c = c+1; % goes to next cell, same velocity

          end
          % now have all cells at that velocity
          tmm = t./2000;

          %IF YOU WANT TO MULTIPLY BY PROB OF LOCATION COMMENT OUT FIRST LINE AND IN SECOND LINE
          endprob(end+1) = (productme) + (-tmm.*expme); %NEW
          %endprob(end+1) = log(probatvelocity(k)) + (productme) + (-tmm.*expme); %NEW


        %  if max(isinf(endprob)) ==1
        %      warning('youve got an infinity')
              %length(ni)
              %log(productme) %this is inf
          %elseif mean(endprob) ==0
          %    warning('youve got all zeros')
          %    endprob
          %end



        end


        [val, idx] = (max(endprob));

        nums = isfinite(endprob);
        nums = find(nums == 1);
      endprob = endprob(nums);

          mp = max(endprob(:))-12;

          endprob = exp(endprob-mp);



            %if max(isinf(test)) == 1
            %endprob = exp(endprob-(max(endprob)*.2));
            %else
          %    endprob = test;
        %    end

            conv = 1./sum(endprob(~isnan(endprob)), 'all');

      endprob = endprob*conv;



        percents = vertcat(percents, endprob);

        maxprob(end+1) = idx;
        perc(end+1) = max(endprob);
        %maxprob(end+1) = find(max(endprob)); %finds most likely range: 1 is for 0-10, 2 for 10-30, etc
                                          % if I want probabilities need to make a matrix of endprobs instead of selecting max
        times(end+1) = timevector(tm);


        if tdecodesec>=.5
          tm = tm+(t/2);
          trainnum = trainnum +1;
        else
          tm = tm+t;
          trainnum = trainnum +1;
        end


end

%length(find(binnedV==4))

%ans = find(binnedV<50);
%[h,p,ci,stats] = ttest2(maxprob, binnedV);
probs = percents;


v = maxprob;

binnum = v;

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


values = [v; times; binnum; perc];

toc

errors=velerror(values, vel)
