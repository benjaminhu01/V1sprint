%===========================================================
function[Age,dot,dob] = getAge(dot, dob)
%===========================================================
Age = 0.0;
[a, dob] = FixDate(dob);
[b, dot] = FixDate(dot);

if a(1)==0 || b(1)==0
    return;
else
	Age = (b(3) - a(3)) + (b(2) - a(2))/365.25 + (b(1) - a(1))/12.0;
	if (Age < 0.5 || Age > 150.0)
		Age = 0.0;
	end
end

%===========================================================
function[n, D] = FixDate(d)
%===========================================================
D = '';
n = sscanf(d, '%hd/%hd/%hd');
if length(n) ~= 3
	n = 0;
%	fprintf(1, 'Cannot fix Date: %s\n', d);
	return;
end
if n(1) < 1 || n(1) > 12
%	fprintf(1, 'Cannot fix Month: %s\n', d);
	return;
end
if n(2) < 1 || n(2) > 31
%	fprintf(1, 'Cannot fix Year: %s\n', d);
	return;
end
if n(3) < 20
	n(3) = n(3) + 2000;
elseif n(3) < 100
	n(3) = n(3) + 1900;
elseif n(3) == 200
	n(3) = 2000;
end

if (n(3) > 1800 && n(3) < 3000)
	D = sprintf('%02d/%02d/%04d', n);
end
%fprintf(1, 'fix_date: %s = %s\n', d, D);

