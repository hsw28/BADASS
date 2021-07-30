function a = accel(pos, varargin);
	%computes acceleraiton. input a [#ofpoints, 3] vector, where first column is time, second is x, third is y
	%varargin is pixels per cm if inputting in pixels. if empty no conversion will be made
	%does not smooth
	% returns matrix of acceleraiton in cm/s^2 and time stamp 

	if length(cell2mat(varargin))>0
		pix_cm = cell2mat(varargin);
	else
		pix_cm = 1;
	end

v = velocity(pos, pix_cm);

vel = v(1, :);
t = v(2, :);

accvector = [];
timevector = [];

s = size(t,2);

for i = 2:s-2
	vchange = vel(i+1)-vel(i-1);
	accel = vchange/(t(i+1)-t(i-1));
	accvector(end+1) = accel;
	timevector(end+1) = t(i);
end


a = [accvector; timevector];
size(a);
