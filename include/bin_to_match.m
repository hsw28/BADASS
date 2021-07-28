function f = bin_to_match(to_bin, bin, overlap, samplingrate)
%bin in seconds, overlap in seconds
%used to bin vel/acc/time whatever to compare with decoded values
%input: %vector to bin
      % bin size (for ex, 1 for 1 second)
      %any bin overlap (for ex, .5 for .5 seconds overlap)
      %sampling rate

samp = samplingrate;
if overlap>0
overlap = overlap*samp;
else
overlap = bin*samp;
end

binsec = bin;
bin = bin*samp;

k=1;
av = [];
while k<length(i)-bin
  av(end+1) = mean(to_bin(k:k+bin));
  k = k+(overlap);
end

f= av;
