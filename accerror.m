function [values median_error mean_error] = acc_error(decodedacc_or_vel_or_vel, acc_or_vel, vbin)
%returns an error in cm^2/s (acc) for each decoded time.
%inputs should be:
                  %decoded acceleration from decodeACC.m
                  %computed acceleration from accel.m
                  %acc bins used in decoding


time = decodedacc_or_vel(2,:);
decodedacc_or_vel = decodedacc_or_vel(1,:);


%get acc lower 5 percent range

binacc = bin_to_match(acc_or_vel(1,:), .5, 0, 30);
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
  [c index] = (min(abs(time(i)-acc_or_vel(2,:))));
  closeacc(end+1) = acc_or_vel(1,index);

  %FOR ONLY GETTING NUMS IN ACC RANGE YOU WANT
  if abs(acc_or_vel(1,index))<100 && abs(acc_or_vel(1,index))>20
    diff = abs(decodedacc_or_vel(i)-acc_or_vel(1,index)); %keep this line always
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


temp2 = values(1,:);
t = ~isnan(temp2);
temp2 = temp2(t);
mean_error = mean(temp2)
median_error = median(temp2)
