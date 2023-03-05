function cn = cnEncode2(x,y)
% DESCRIPTION:
% Compute a unique integar using 2 integers

% INPUT: 
% x, y - numbers 

% OUTPUT: 
% characteristic number

x = int64(x);
y = int64(y);

cn = (x + y + 1).*(x + y)/2 + y;

