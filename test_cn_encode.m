clear, clc, close all

% first two numbers
x = 150;
y = 49;

% reversing input ordering changes output 
cn = encode_cn(x, y);
disp(cn)
cn = encode_cn(y, x);
disp(cn)

% input a 3rd number 
z = 27;
cn = encode_cn(x, y, z);
disp(cn)