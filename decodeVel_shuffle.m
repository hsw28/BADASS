function f = decodeVel_shuffle(clusters, vel, tdecode, pos, bin, dim, perms, varargin)
% shuffles spike times and decodes speed based on shuffled cell firing.
% calculates med and mean error for shuffled data, as well as spearman's rho
% inputs =
            %structure of clusters
            %actual speed from velocity.m
            %tdecode = bin to decode in seconds. if this is >= 1 seconds there will be 2/tdecode overlap in decoding
            %position data
            %bin: = size of bins to bin vel into. we use 7cm/s per bin as default . this will always be symetric around zero
            %dim = dimension of bins in cm to use for spearman's rho (see spearman_rankresults.m).
            %perms: number of times to repeat the shuffle
           % varagin = pixels per cm if inputting position in pixels. if empty no conversion will be made
%ex: decodeVel_shuffle(clusters, vel, .5, position, 7, 10, 100, 3.5);
% returns medians, means, and spearman's rho for all shuffled trials and prints out what error would need to be smaller than to be less than 95% of shuffles

set(0,'DefaultFigureVisible', 'off');

if length(cell2mat(varargin)) > 0
    pix_cm = cell2mat(varargin);
else
    pix_cm = 1;
end

timevector = vel(2,:);
timeextra = [timevector(1):1/2000:timevector(end)];
timelength = length(timeextra);

clustname = (fieldnames(clusters));
numclust = length(clustname);
med = [];
av = [];
rhovec = [];
for z = 1:perms
  for k=1:numclust
    name = char(clustname(k));
    firingdata = clusters.(name);
    firelength = length(firingdata);
    randselect = randperm(timelength, firelength);
    newclust = timeextra(randselect);
    shuffclust.(name) = newclust;
  end


  [values errors] = decodeVel(shuffclust, vel, tdecode, bin);
  [f pval rho]= spearman_rankresults(pos, vel, values, dim, pix_cm);
  rhovec(end+1)= rho;
  med(end+1) = nanmedian(errors(1,:));
  av(end+1) = nanmean(errors(1,:));

end

f = [med;av;rhovec]';

lowest = round(length(med)*.05);
med = sort(med);
av = sort(av);
if lowest<1
  fprintf('too few permutations to compute 95% cutoff')
else
fprintf('95 cutoff for median error is')
med(lowest)
fprintf('95 cutoff for mean error is')
av(lowest)
fprintf('95 cutoff for spearmans rho is')
rhovec(length(rhovec)-lowest)
end

set(0,'DefaultFigureVisible', 'on');
