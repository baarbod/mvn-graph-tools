function cn = encodecn(varargin)
% DESCRIPTION:
% Compute a unique integar using 2 oe 3 integers

% INPUT: 
% x, y, z(optional) - numbers 

% OUTPUT: 
% unique integer refered to as characteristic number

switch nargin
    case 2
        x = int64(varargin{1});
        y = int64(varargin{2});
        cn = (x + y + 1).*(x + y)/2 + y;
    case 3
        x = int64(varargin{1});
        y = int64(varargin{2});
        z = int64(varargin{3});
        cn2 = (y + z + 1).*(y + z)/2 + z;
        cn = (x + cn2 + 1).*(x + cn2)/2 + cn2;
end


