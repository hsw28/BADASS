function values  = acc_error(decodedacc, acc, tdecode)
%returns an error in cm^2/s (acc) for each decoded time.
%inputs should be:
                  %decoded acceleration from decodeACC.m
                  %computed acceleration from accel.m
                  %decoded time bin in s
%returns: values = [alldiff; realvel; time];
        %difference in decoded acc versus actual
        %actual acc
        %time of decoding



time = decodedacc(2,:);
decodedacc = decodedacc(1,:);


%get acc lower 5 percent range
if tdecode>=.5
  overlap = tdecode./2;
else
  overlap = 0;
end
samprate = length(acc)./(max(acc(2,:))-min(acc(2,:)));
samprate = round(samprate);
binacc = bin_to_match(acc(1,:), tdecode, overlap, samprate);
numwewant = length(binacc)*.05;
[N,EDGES] = histcounts(binacc,length(binacc));
k = length(N);
z = 0;
while z<numwewant
  z = z+N(k);
  k = k-1;
end
lim = EDGES(k)

alldiff = [];
closeacc = [];
for i=1:length(time)
  [c index] = (min(abs(time(i)-acc(2,:))));
  closeacc(end+1) = acc(1,index);

  %FOR ONLY GETTING NUMS IN ACC RANGE YOU WANT
  if abs(acc(1,index))<100 && abs(acc(1,index))>20
    diff = abs(decodedacc(i)-acc(1,index)); %keep this line always
  else
    diff = NaN;
  end


  if abs(closeacc(end))<=lim
    alldiff(end+1) = diff;
  else
    alldiff(end+1) = NaN;
  end
end
realacc = closeacc;


values = [alldiff; realacc; time];


fprintf('you errors are:')
mean_error = nanmean(temp2)
median_error = nanmedian(temp2)
