function [f pval]= spearman_rankresults(actual_pos, actual_vel_or_acc, decoded_vel_or_acc, dim, varagin)
%uses spearman's rho to compute accuracy of decoding
%input actual position and actual velocity/acc and then decoded acc or vel from decodeACC or decodeVel
%ranks positions from fastest to slowest based on actual velocity or acceleration
%then ranks positions from fastest to slowest based on decoded
%compares order of positions based on both rankings and outputs spearman's rho and a graph of comparisions
      %inputs = %actual positon [#ofpoints, 3] vector, where first column is time, second is x, third is y
                %actual velocity from velocity.m or acc from accel.m
                % decoded acc or vel from from decodeACC or decodeVel
                %bin to divide positions in, in cm
                % varagin = pixels per cm if inputting in pixels. if empty no conversion will be made
      %returns f = ranks of different positions
              %pval = spearman's rho p value




actual_pos = pos1;
actual_vel_or_acc = vel1;
actual_pos = pos2;
decoded_vel_or_acc = vel2;
dimX = dim;
dimY = dim;

bounded = cell2mat(varargin);


  rank1 = velrank(pos1, vel1, dimX, dimY,varargin);
  rank2 = velrank(pos2, vel2, dimX, dimY, varargin);



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
%good = find(rank1(:,3)>7);
%rank1 = rank1(good,:);
%rank2 = rank2(good,:);
%good = find(rank2(:,3)>7);
%rank1 = rank1(good,:);
%rank2 = rank2(good,:);


rank1 = sortrows(rank1, 3);
rank2 = sortrows(rank2, 3);
%num = find(~isnan(rank2(:, 3)));
neworder = [1:1:length(rank1)];
newrank1 = [neworder', rank1(:, 2:4)];
newrank2 = [neworder', rank2(:, 2:4)];
rank1 = sortrows(newrank1, 2);
rank2 = sortrows(newrank2, 2);

%f = [rank1, rank2];


x = rank1(:,1);
y = rank2(:,1);
%good = find(~isnan(x));
%x = x(good);
%y = y(good);
%good = find(~isnan(y));
%x = x(good);
%y = y(good);

f = [rank1, rank2];



scatter(x, y);
[rho,pval] = corr(x,y, 'Type','Spearman');
str1 = {'Spearmans rho' rho, 'P value' pval};
%[rho,pval] = corr(x,y,'Type','Kendall')
%str2 = {'Kendalls rho' rho, 'P value' pval};
xlabel('Actual Position Rank from Slowest Average Speed to Fastest')
ylabel('Decoded Position Rank from Slowest Average Decoded Speed to Fastest')
text(1.2,max(y)*.9,str1);
