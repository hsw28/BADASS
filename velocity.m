function v = velocity(pos, varargin);
%computes velocity. input a [#ofpoints, 3] vector, where first column is time, second is x, third is y
%varargin is pixels per cm if inputting in pixels. if empty no conversion will be made
%does not smooth
% returns matriix of speeds in cm/s and time stamp m

if length(cell2mat(varargin))>0
	pix_cm = cell2mat(varargin);
else
	pix_cm = 1;
end

file = pos;
%file = fixpos(pos);

file = file';
t = file(1, :);
xpos = (file(2, :))';
ypos = (file(3, :))';



velvector = [];
timevector = [];

s = size(t,2);

for i = 2:s-1
	%find distance travelled
	if t(i)~=t(i-1)
		hypo = hypot((xpos(i-1)-xpos(i+1)), (ypos(i-1)-ypos(i+1)));
		vel = hypo./((t(i+1)-t(i-1)));
		velvector(end+1) = vel;
		timevector(end+1) = t(i);
	end
end

%velvector = filloutliers(velvector, 'pchip', 'movmedian',10);

v = velvector(1:length(timevector));
v = [(v/pix_cm); timevector];
