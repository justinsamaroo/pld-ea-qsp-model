function qsp_export_figure(f,out,base,widthMM,heightMM,includeTIFF)
if nargin<6, includeTIFF = false; end
if ~isfolder(out), mkdir(out); end
if isprop(f,'WindowState'), f.WindowState = 'normal'; end
f.Units = 'centimeters';
f.Position(3:4) = [widthMM heightMM]/10;
drawnow;
sizeArgs = {'BackgroundColor','white','Units','centimeters', ...
    'Width',widthMM/10,'Height',heightMM/10, ...
    'Padding','figure','PreserveAspectRatio','on'};
exportgraphics(f,fullfile(out,[base '.pdf']),sizeArgs{:},'ContentType','vector');

if ~includeTIFF, return; end
if ~isfolder(fullfile(out,'TIFF_CMYK')), mkdir(fullfile(out,'TIFF_CMYK')); end

% Rasterize at 1000 dpi, then write a genuine four-channel CMYK TIFF.
% MATLAB's exportgraphics does not directly export CMYK TIFF files.
temporary = [tempname '.tif'];
exportgraphics(f,temporary,sizeArgs{:},'Resolution',1000);
rgb = imread(temporary); delete(temporary);
assert(isa(rgb,'uint8'),'Unexpected raster bit depth.');
if size(rgb,3)==1, rgb = repmat(rgb,1,1,3); end
assert(size(rgb,3)==3,'Expected an RGB raster before CMYK conversion.');
[height,width,~] = size(rgb);
target = fullfile(out,'TIFF_CMYK',[base '.tif']);
t = Tiff(target,'w');
guard = onCleanup(@() close(t));
t.setTag(struct('ImageLength',height,'ImageWidth',width, ...
    'Photometric',Tiff.Photometric.Separated,'InkSet',Tiff.InkSet.CMYK, ...
    'BitsPerSample',8,'SamplesPerPixel',4, ...
    'PlanarConfiguration',Tiff.PlanarConfiguration.Chunky, ...
    'Compression',Tiff.Compression.LZW,'RowsPerStrip',128, ...
    'ResolutionUnit',Tiff.ResolutionUnit.Inch,'XResolution',1000,'YResolution',1000));
for first = 1:128:height
    last = min(first+127,height);
    R = single(rgb(first:last,:,:))/255;
    K = 1-max(R,[],3);
    CMY = (1-R-K)./max(1-K,eps('single'));
    pixels = uint8(round(255*cat(3,max(0,min(1,CMY)),K)));
    t.writeEncodedStrip((first-1)/128+1,pixels);
end
clear guard;
info = imfinfo(target);
assert(abs(info.XResolution-1000)<1 && abs(info.YResolution-1000)<1, ...
    'TIFF resolution check failed.');
fprintf('Saved %s: vector PDF and 1000 dpi CMYK TIFF.\n',base);
end
