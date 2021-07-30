function values  = acc_error(decodedacc, acc, tdecode)
%returns an error in cm^2/s (acc) for each decoded time.
%inputs should be:
  %decoded acceleration from decodeAcc.m
  %computed acceleration from accel.m
  %decoded time bin in s
%returns: values = [alldiff; realacc; time];
  %difference in decoded acc versus actual
  %mean actual acc in the bin
  %time of decoding



  decodedacc = decodedacc(1,:);
  actualacc = acc(1,:);
  time = acc(2,:);


  tdecodesec = tdecode;
  samprate = length(acc)./(max(acc(2,:))-min(acc(2,:)));
  samprate = (samprate);

  tdecode = round(samprate*tdecode);
  average_acc = [];
  diff = [];
  decodedtime = [];
  realtime = [];
  tm = 1;
  j = 1;


  while tm<=(length(time)-tdecode)
    average_acc(end+1) = nanmean(actualacc(tm:tm+tdecode));
    diff(end+1) = abs(decodedacc(j)-average_acc(end));
    decodedtime(end+1) = time(j);
    time(tm);
    j = j+1;
    if tdecodesec>=.5
      tm = tm+(tdecode/2); %overlap
    else
      tm = tm+tdecode;
    end
  end

  values = [diff; average_acc; decodedtime];
  fprintf('you errors are:')
  median_is = nanmedian(diff)
  mean_is = nanmean(diff)
