function [f pval rho]= spearman_rankresults(actual_pos, actual_vel_or_acc, decoded_vel_or_acc, dim, varargin)
%uses spearman's rho to compute accuracy of decoding. It ranks binned positions from fastest to slowest based on
%actual speed or acceleration, and then ranks the samee positions from fastest to slowest based on decoded speed or acc.
%it compares the two orders of positions based on both rankings and outputs a pval based on spearman's rho and a graph of comparisions
      %inputs = %actual positon [#ofpoints, 3] vector, where first column is time, second is x, third is y
                %actual velocity from velocity.m or acc from accel.m
                % decoded acc or vel from from decodeACC or decodeVel
                %bin to divide positions in, in cm
                % varagin = pixels per cm if inputting position in pixels. if empty no conversion will be made
      %returns f = ranks of different positions as follows:
                %column 1 and 4: speed or acceleration ranks where lower numbers are slower. column 1 is actual, column 4 is decoded
                %column 2 and 5: position bin number.
                %column 3 and 6: average speed or acceration for position bin. column 3 is actual, column 6 is decoded

          %pval = spearman's rho p value
          %rho = spearman's rho



if length(cell2mat(varargin))>0
  pix_cm = cell2mat(varargin);
  else
  pix_cm = 1;
end

pos1 = actual_pos;
vel1 = actual_vel_or_acc;
pos2 = actual_pos;
vel2 = decoded_vel_or_acc;
dimX = dim;
dimY = dim;

bounded = cell2mat(varargin);


  rank1 = velrank(pos1, vel1, dimX, dimY, pix_cm);
  rank2 = velrank(pos2, vel2, dimX, dimY, pix_cm);



rank1.order = sortrows(rank1.order, 2);
rank2.order = sortrows(rank2.order, 2);


if length(rank2.order)==0
  warning('YOU HAVE NO OVERLAP DECODING')
end

good = find(~isnan(rank1.order(:, 3)));
rank1 = rank1.order(good,:);
rank2 = rank2.order(good,:);
good = find(~isnan(rank2(:, 3)));
rank1 = rank1(good,:);
rank2 = rank2(good,:);



rank1 = sortrows(rank1, 3);
rank2 = sortrows(rank2, 3);
%num = find(~isnan(rank2(:, 3)));
neworder = [1:1:length(rank1)];
newrank1 = [neworder', rank1(:, 2:3)];
newrank2 = [neworder', rank2(:, 2:3)];
rank1 = sortrows(newrank1, 2);
rank2 = sortrows(newrank2, 2);



x = rank1(:,1);
y = rank2(:,1);


f = [rank1, rank2];


figure
scatter(x, y);
[rho,pval] = corr(x,y, 'Type','Spearman');
str1 = {'Spearmans rho' rho, 'P value' pval};
%[rho,pval] = corr(x,y,'Type','Kendall')
%str2 = {'Kendalls rho' rho, 'P value' pval};
xlabel('Actual Position Rank from Slowest Average Speed to Fastest')
ylabel('Decoded Position Rank from Slowest Average Decoded Speed to Fastest')
text(1.2,max(y)*.9,str1);
pval = pval
