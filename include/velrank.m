function f = velrank(posData, vel, dimX, dimY, varargin)
%include function to rank positions for spearman_rankresults


if length(cell2mat(varargin))>0
	pix_cm = cell2mat(varargin);
else
	pix_cm = 1;
end

psizeX = pix_cm * dimX; %some REAL ratio of pixels to cm
psizeY = pix_cm * dimY;

%determine which position is being used
if size(posData,2) == 3 %this means non decoded
  mintimepos = min(posData(:,1));
  maxtimepos = max(posData(:,1));
  timepos = posData(:,1);
  X = (posData(:,2));
  Y = (posData(:,3));


elseif size(posData,1)==4 %means decoded continuous


  highprobpos = find(posData(3,:)>0);
  posData = posData(:,highprobpos);



  mintimepos = min(posData(4,:));
  maxtimepos = max(posData(4,:));
  timepos = posData(4,:)';
  X = (posData(1,:))';
  Y = (posData(2,:))';

end


if size(vel,1)==4

  highprobvel = find(vel(4,:)>0);
  vel = vel(:,highprobvel);
  mintimevel = min(vel(2,:));
  maxtimevel = max(vel(2,:));
  timevel = vel(2,:);
  vel = vel(1,:);

%THIS MIGHT NEED REVISING
elseif size(vel,1)==5
  highprobvel = find(vel(3,:)>0);
  vel = vel(:,highprobvel);

  mintimevel = min(vel(4,:));
  maxtimevel = max(vel(5,:));
  timevel = (vel(4,:));
  vel = vel(1,:);
  %%%%%

else
  mintimevel = min(vel(2,:));
  maxtimevel = max(vel(2,:));
  timevel = vel(2,:);
  vel = vel(1,:);

end
%%ENDDDDD


%cut so same

if mintimepos>mintimevel
  %cut vel start
  [c indexmin] = (min(abs(timevel-mintimepos)));
  timevel = timevel(indexmin:end);
  vel = vel(indexmin:end);
  fprintf('1')
elseif mintimepos<mintimevel
  %cut pos start
  [c indexmin] = (min(abs(timepos-mintimevel)));
  timepos = timepos(indexmin:end);
  X = X(indexmin:end);
  Y = Y(indexmin:end);
end



if  maxtimepos>maxtimevel
  %cut pos end
  [c indexmin] = (min(abs(timepos-maxtimevel)));
  timepos = timepos(1:indexmin);
  X = X(1:indexmin);
  Y = Y(1:indexmin);
elseif maxtimepos < maxtimevel
  %cut vel end
  [c indexmin] = (min(abs(timevel-maxtimepos)));
  timevel = timevel(1:indexmin);
  vel = vel(1:indexmin);
end



posData = [timepos, X, Y];
timesforvel = placeevent(timevel, posData); %vectortxy = [time'; xposvector; yposvector];
timesforvel = timesforvel';




all = 0;



xmin = min(X);
ymin = min(Y);
xmax = max(X);
ymax = max(Y);
xbins = ceil((xmax-xmin)/psizeX); %number of x
ybins = ceil((ymax-ymin)/psizeY); %number of y
xstep = xmax/xbins;
ystep = ymax/ybins;
xinc = xmin +(0:xbins)*psizeX; %makes a vectors of all the x values at each increment
yinc = ymin +(0:ybins)*psizeY; %makes a vector of all the y values at each increment

averagecells = zeros(xbins, ybins);
numincells = zeros(xbins,ybins);


  for x = (1:xbins) %WANT TO PERMUTE THROUGH EACH SQUARE OF SPACE SKIPPING NON OCCUPIED SQUARES. SO EACH BIN SHOULD HAVE TWO COORDINATES
    for y = (1:ybins)
        if x<xbins & y<ybins
          inX = find(timesforvel(:,2)>=xinc(x) & timesforvel(:,2)<xinc(x+1));
          inY = find(timesforvel(:,3)>=yinc(y) & timesforvel(:,3)<yinc(y+1));
        elseif x==xbins & y<ybins
          inX = find(timesforvel(:,2)>=xinc(x));
          inY = find(timesforvel(:,3)>=yinc(y) & timesforvel(:,3)<yinc(y+1));
        elseif x<xbins & y==ybins
          inX = find(timesforvel(:,2)>=xinc(x) & timesforvel(:,2)<xinc(x+1));
          inY = find(timesforvel(:,3)>=yinc(y));
        elseif x==xbins & y==ybins
          inX = find(timesforvel(:,2)>=xinc(x));
          inY = find(timesforvel(:,3)>=yinc(y));
        end
    %  end

        inboth = intersect(inX, inY); %inboth is the velocity index for cells in that bin
        if length(inboth)>0
          velinboth = vel(inboth);
          avinboth = nanmean(velinboth);
          averagecells(x, y) = avinboth;
          numincells(x,y) = length(inboth);
          all = all+length(inboth);
        else
          averagecells(x, y) = NaN;
          numincells(x,y) = NaN;
        end
      end

      linearmean = reshape(averagecells,[1 xbins*ybins]);
      linearnum = reshape(numincells,[1 xbins*ybins]);
    end






if all>1000

  low = find(linearnum<=ceil(all*.005));
  linearmean(low) = NaN;
else
  low = find(linearnum<=2);
  linearmean(low) = NaN;
end

length(linearmean)-length(low)

%  linearmean(low) = NaN;
  [avs,idx] = sort(linearmean);
  sorted = [[1:1:length(idx)]; idx; avs; linearnum(idx)]';

  sortnan = find(isnan(sorted(:,3)));
  sorted(sortnan,1) = NaN;


  f.averages =  averagecells;
  f.samples =   numincells;
  f.order = sorted;
