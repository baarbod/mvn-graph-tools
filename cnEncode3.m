function cn = cnEncode3(x, y, z)
% DESCRIPTION:
% Compute a unique integar using 3 integars

% INPUT: 
% x, y, z - numbers of any type

% OUTPUT: 
% characteristic number 

x = int64(x);
y = int64(y);
z = int64(z);

pi_yz = cnEncode2(y, z);

cn = cnEncode2(x, pi_yz);
