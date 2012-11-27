function [p, msh] = AFQ_RenderCorticalSurface(cortex, varargin)
% Render the cortical surface from a binary segmentation image
%
% [p, msh] = AFQ_RenderCorticalSurface(cortex, color, a, overlay, thresh, crange, cmap, newfig)
%
% This function takes in a segmentation image and renders it in 3d. It is
% optimized to look good for the cortical surface but any image will work.
% The rendering will be added to the current figure window so you can add
% the cortex to a rendering of fiber groups and adjust it's transparency
%
% Inputs:
% cortex  - A msh, mesh structure (see AFQ_meshCreate) or a path to a 
%           nifti image to render. It must be a binary mask.
% color   - RGB value for the surface of the rendering. Default is "brain"
%           color
% alpha   - The transparency of the surface (alpha). 0 is completely
%           transparent and 1 is completely opaque
% overlay - Another image to use to color the surface (for example an fMRI
%           contrast).
% thresh  - A threshold above/below which now overlay values will be
%           painted on the cortex and the cortex will be left cortex
%           colored. Thresh can be a single number (minumum) or a vector of
%           2 numbers (minimum and maximum).
% crange  - Define which overlay values should be mapped to the minimum and
%           maximum values of the color map. All values below crange(1)
%           will be colored the minimum value and all values above
%           crange(2) will be colored the maximum value. The default color
%           range is defined by the minimum and maximum values of the
%           overlay image that get mapped to any mesh vertex.
% cmap    - Name of the colormap to use. For example 'jet' or 'autumn'
% newfig  - Whether or not to open a new figure window
%
% Outputs:
% p       - Handel for the patch object that was added to the figure
%           window. The rendering can be deleted with delete(p)
% msh     - The mesh object of the cortical surface.
%
% Example:
%
% % Get data
% [~, AFQdata] = AFQ_directories; 
% cortex = fullfile(AFQdata,'mesh','segmentation.nii.gz');
% overlay = fullfile(AFQdata,'mesh','t1.nii.gz');
% % Render the cortical surface colored by the T1 values at each vertex
% p = AFQ_RenderCorticalSurface(cortex, [], [], overlay)
%
% Copyright Jason D. Yeatman November 2012

% Create a parameters structure from any parameters that were defined
params = CreateParamsStruct(varargin);

if ~isfield(params,'alpha')
    params.alpha = 1;
end

if ~isfield(params,'newfig')
    params.newfig = 1;
end
%% Build a mesh of the cortical surface

% If a msh structure was sent in then get the triangles. If an image was
% sent in then build a mesh with the defined parameters
if ismesh(cortex)
    tr = AFQ_meshGet(cortex,'triangles');
else
    msh = AFQ_meshCreate(cortex, params);
    tr = AFQ_meshGet(msh, 'triangles');
end

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % Load the image
% im = readFileNifti(cortex);
% % permute the image dimensions (This is because the x,y and z dimensions in
% % matlab do not correspond to left-right, anterior-posterior, up-down.
% data = permute(im.data, [2 1 3]);
% % smooth the image
% data = smooth3(data,'box',5);
% % make a mesh
% msh = isosurface(data,.1);
% % transform the vertices to acpc space
% msh.vertices = mrAnatXformCoords(im.qto_xyz,msh.vertices);
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

%% Render the cortical surface
if params.newfig == 1
    figure;
end
% Use patch to render the mesh
p = patch(tr);
%p = patch(tr,'facecolor',color,'edgecolor','none');

% Interpolate the coloring along the surface
shading('interp'); 
% Set the type of lighting
lighting('gouraud');
% Set the alpha
alpha(p,params.alpha);
% Set axis size
axis('image');axis('vis3d');
% Set lighiting options of the cortex
set(p,'specularstrength',.5,'diffusestrength',.75);

% If it was a new figure window add a light to it
if params.newfig == 1
    camlight('right');
end