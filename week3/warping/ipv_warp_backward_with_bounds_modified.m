%% EEEM010 - Image Processing and Vision (eem.ipv)
%%
%% ipv_warp_backward.m
%% Demonstrating of an image warp under affine transformation
%% using backward mapping and nearest neighbour 'interpolation'.
%%
%% Usage:  ipv_warp_backward
%%
%% IN:  N/A 
%% 
%% OUT: N/A
%%
%% (c) John Collomosse 2015  (J.Collomosse@surrey.ac.uk)
%% Centre for Vision Speech and Signal Processing (CVSSP)
%% University of Surrey, United Kingdom

close all;
clear all;

INPUT_IMAGE = 'surrey.png';

% img_in=double(imread(INPUT_IMAGE))./255;
img_in=ipv_cheqpattern(500,500,3,3);
img_in=imgaussfilt(img_in,1);

H=size(img_in,1);  % height
W=size(img_in,2);  % width

th=pi/3;
R=[cos(th) -sin(th) 0 ; ...
   sin(th)  cos(th) 0 ; ...
   0        0       1];

sf=0.3
S=[sf 0 0 ; ...
   0  sf 0 ; ...
   0        0       1];

T=[1 0 -W/2 ; ...
   0 1 -H/2 ; ...
   0 0 1];

M=inv(T)*S*R*T;
% warp 4 corners
corners=[1 1 H W ; 1 W W 1];
corners(3,:)=1;
warped_corners=M*corners;
minx=min(warped_corners(1,:));
maxx=max(warped_corners(1,:));
miny=min(warped_corners(2,:));
maxy=max(warped_corners(2,:));

shift=[1 0 -minx ; 0 1 -miny ; 0 0 1];
M=shift*M;
newW=ceil(maxx-minx+1);
newH=ceil(maxy-miny+1);

img_out=zeros(newH,newW,3);

M=inv(M);
for x=1:newW
    for y=1:newH
        
        q = [x ; y ; 1];
        p = M * q;
        
        u = p(1)/p(3);
        v = p(2)/p(3);

        vertblend = u - floor(u);
        horizblend = v - floor(v);
        
        if (u>1 & u<=W-1 & v>1 & v<=H-1)
           A=img_in(floor(v),floor(u),:);
           B=img_in(ceil(v),floor(u),:);
           C=img_in(floor(v),ceil(u),:);
           D=img_in(ceil(v),ceil(u),:);
           E=A*(1-vertblend) + C*vertblend;
           F=B*(1-vertblend) + D*vertblend;
           
           G=(1-horizblend)*E + horizblend*F;
           
           img_out(y,x,:)= G;
        end
        
    end
end

imgshow(img_out);
