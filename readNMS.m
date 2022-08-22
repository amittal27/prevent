function [depthmap,lasermap,pixelsize_um] = readNMS( filename )
%readNMS Read Nanofocus measurement files

extAdress = 16;

posAdress8 = hex2dec('558');
sizeAdress16 = 4;%
posHdata8 = hex2dec('D8C');
sizePixelsize64 = 16; % size pixelsize

fid = fopen(filename,'r');
if fid > 0
    skippeddata = fread(fid,extAdress,'uint8'); % skip data to get to extend / min/max value

    % read first part of header
    vec = fread(fid,2,'double');
    maxval = vec(2);
    minval = vec(1);

    % image width
    skippeddata=fread(fid,posAdress8-32,'uint8'); % skip data to get to image size
    vec = fread(fid,sizeAdress16,'uint16');
    width = vec(1);
    height = vec(3);
    
    % image pixelsize
    vec = fread(fid,2,'double');
    pixelsize_um(1) = vec(1)/1000;
    pixelsize_um(2) = vec(2)/1000;
    
    % skip some irrelevant data blocks
    skipdata = posHdata8 - posAdress8 - 2*sizeAdress16 - sizePixelsize64;
    skippeddata=fread(fid,skipdata,'uint8'); % skip data

    % read depth data
    vec = fread(fid,width*height,'uint16');
    depthmap = rot90(reshape(vec,[width,height]));
    NM = depthmap == 0;
    depthmap = (depthmap) / ((2^16)-2) * (maxval-minval) + minval;
    depthmap(NM) = NaN;
    
    % read laservalue data
    vec = fread(fid,width*height,'uint8');
    if numel(vec>0)
        lasermap = rot90(reshape(vec,[width,height]));
        NM = lasermap == 0;
        depthmap(NM) = NaN;
    else
        lasermap = rot90(depthmap*0);
    end

    fclose(fid);
else
    depthmap = [];
    lasermap = [];
    pixelsize_um = [];
end

end