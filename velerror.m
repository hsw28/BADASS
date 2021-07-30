function values = velerror(decodedvel, vel, tdecode)
%returns an error in cm/s (vel) for each decoded time.
%inputs should be:
                  %decoded vell from decodeVel.m
                  %computed vel from velocity.m
                    %decoded time bin in s
%returns: values = [alldiff; realvel; time];
    %difference in decoded speed versus actual
    %mean actual speed in the bin
    %time of decoding



decodedvel = decodedvel(1,:);
actualvel = vel(1,:);
time = vel(2,:);



tdecodesec = tdecode;
samprate = length(vel)./(max(vel(2,:))-min(vel(2,:)));
samprate = (samprate);

tdecode = round(samprate*tdecode);
average_vel = [];
diff = [];
decodedtime = [];
realtime = [];
tm = 1;
j = 1;


while tm<=(length(time)-tdecode)
  average_vel(end+1) = nanmean(actualvel(tm:tm+tdecode));
  diff(end+1) = abs(decodedvel(j)-average_vel(end));
  decodedtime(end+1) = time(j);
  j = j+1;
  if tdecodesec>=1
    tm = tm+(tdecode/2); %overlap
  else
    tm = tm+tdecode;
  end
end

values = [diff; average_vel; decodedtime];

median_is = nanmedian(diff);
mean_is = nanmean(diff);
