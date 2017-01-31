function [emdSTEM,psi] = PRISM03_gpu(emdSTEM)
tic

% 03 - compute outputs from compact S matrix into 3D STEM outputs

% Inputs
% emdSTEM.probeDefocusArray = [-80 -40 0];%[-40 -30 -20 -10 0];%[-40 -20 0];%[-100 -50 0];  % in Angstroms      % dim 4
% emdSTEM.probeSemiangleArray = [70 50 30 10]/1000;%fliplr([25 50 75])/1000;%25/1000;  % rads      % dim 5
emdSTEM.probeDefocusArray = 0;%[-40 0 40];%[-80 -60 -40 -20 0 20];%[-40 -30 -20 -10 0];%[-40 -20 0];%[-100 -50 0];  % in Angstroms      % dim 4
emdSTEM.probeSemiangleArray = 20/1000;%[30 20 10]/1000;%fliplr([25 50 75])/1000;%25/1000;  % rads      % dim 5
emdSTEM.probeXtiltArray = 0/1000;  % rads           % dim 6
emdSTEM.probeYtiltArray = 0/1000;  % rads           % dim 7
% Probe positions
dxy = 0.25 * 2;
% xR = [0.3 0.5]*emdSTEM.cellDim(1);
% yR = [0.65 0.85]*emdSTEM.cellDim(2);
% xR = [0.40 0.45]*emdSTEM.cellDim(1);
% yR = [0.70 0.75]*emdSTEM.cellDim(2);
xR = [0.1 0.9]*emdSTEM.cellDim(1);
yR = [0.1 0.9]*emdSTEM.cellDim(2);
emdSTEM.xp = (xR(1)+dxy/2):dxy:(xR(2)-dxy/2);
emdSTEM.yp = (yR(1)+dxy/2):dxy:(yR(2)-dxy/2);
% emdSTEM.xp = 50;
% emdSTEM.yp = 50;
% Detector output angles
dr = 2.5 / 1000;
alphaMax = emdSTEM.qMax * emdSTEM.lambda;
emdSTEM.detectorAngles = (dr/2):dr:(alphaMax-dr/2);
flag_plot = 0;
flag_keep_beams = 0;

% Realspace coordinate system
r = emdSTEM.imageSizeOutput / emdSTEM.interpolationFactor / 2;
xVec = ((-r(1)):(r(1)-1));
yVec = ((-r(2)):(r(2)-1));

% Downsampled beams
emdSTEM.beamsReduce = emdSTEM.beamsOutput( ...
    1:(emdSTEM.interpolationFactor):end,...
    1:(emdSTEM.interpolationFactor):end);
imageSizeReduce = size(emdSTEM.beamsReduce);
xyBeams = zeros(length(emdSTEM.beamsIndex),2);
for a0 = 1:emdSTEM.numberBeams;
    [~,ind] = min(abs(emdSTEM.beamsReduce(:) - a0));
    [xx,yy] = ind2sub(imageSizeReduce,ind);
    xyBeams(a0,:) = [xx yy];
end

% Generate detector downsampled coordinate systemfunction [emdSTEM,psi] = PRISM03(emdSTEM)
tic

% 03 - compute outputs from compact S matrix into 3D STEM outputs

% Inputs
% emdSTEM.probeDefocusArray = [-80 -40 0];%[-40 -30 -20 -10 0];%[-40 -20 0];%[-100 -50 0];  % in Angstroms      % dim 4
% emdSTEM.probeSemiangleArray = [70 50 30 10]/1000;%fliplr([25 50 75])/1000;%25/1000;  % rads      % dim 5
emdSTEM.probeDefocusArray = 0;%[-40 0 40];%[-80 -60 -40 -20 0 20];%[-40 -30 -20 -10 0];%[-40 -20 0];%[-100 -50 0];  % in Angstroms      % dim 4
emdSTEM.probeSemiangleArray = 20/1000;%[30 20 10]/1000;%fliplr([25 50 75])/1000;%25/1000;  % rads      % dim 5
emdSTEM.probeXtiltArray = 0/1000;  % rads           % dim 6
emdSTEM.probeYtiltArray = 0/1000;  % rads           % dim 7
% Probe positions
dxy = 0.25 * 2;
% xR = [0.3 0.5]*emdSTEM.cellDim(1);
% yR = [0.65 0.85]*emdSTEM.cellDim(2);
% xR = [0.40 0.45]*emdSTEM.cellDim(1);
% yR = [0.70 0.75]*emdSTEM.cellDim(2);
xR = [0.1 0.9]*emdSTEM.cellDim(1);
yR = [0.1 0.9]*emdSTEM.cellDim(2);
emdSTEM.xp = (xR(1)+dxy/2):dxy:(xR(2)-dxy/2);
emdSTEM.yp = (yR(1)+dxy/2):dxy:(yR(2)-dxy/2);
% emdSTEM.xp = 50;
% emdSTEM.yp = 50;
% Detector output angles
dr = 2.5 / 1000;
alphaMax = emdSTEM.qMax * emdSTEM.lambda;
emdSTEM.detectorAngles = (dr/2):dr:(alphaMax-dr/2);
flag_plot = 0;
flag_keep_beams = 0;

% Realspace coordinate system
r = emdSTEM.imageSizeOutput / emdSTEM.interpolationFactor / 2;
xVec = ((-r(1)):(r(1)-1));
yVec = ((-r(2)):(r(2)-1));

% Downsampled beams
emdSTEM.beamsReduce = emdSTEM.beamsOutput( ...
    1:(emdSTEM.interpolationFactor):end,...
    1:(emdSTEM.interpolationFactor):end);
imageSizeReduce = size(emdSTEM.beamsReduce);
xyBeams = zeros(length(emdSTEM.beamsIndex),2);
for a0 = 1:emdSTEM.numberBeams;
    [~,ind] = min(abs(emdSTEM.beamsReduce(:) - a0));
    [xx,yy] = ind2sub(imageSizeReduce,ind);
    xyBeams(a0,:) = [xx yy];
end

% Generate detector downsampled coordinate system
qxaReduce = emdSTEM.qxaOutput( ...
    1:emdSTEM.interpolationFactor:end,...
    1:emdSTEM.interpolationFactor:end);
qyaReduce = emdSTEM.qyaOutput( ...
    1:emdSTEM.interpolationFactor:end,...
    1:emdSTEM.interpolationFactor:end);
Ndet = length(emdSTEM.detectorAngles);

% figure(56)
% clf
% imagesc(qxaReduce)
% axis equal off

% Initialize pieces
emdSTEM.stackSize = [ ...
    length(emdSTEM.xp) ...
    length(emdSTEM.yp) ...
    length(emdSTEM.detectorAngles) ...
    length(emdSTEM.probeDefocusArray) ...
    length(emdSTEM.probeSemiangleArray) ...
    length(emdSTEM.probeXtiltArray) ...
    length(emdSTEM.probeYtiltArray)];
emdSTEM.stack = zeros(emdSTEM.stackSize,'single');
q1 = zeros(imageSizeReduce);
q2 = zeros(imageSizeReduce);
dq = mean([qxaReduce(2,1) qyaReduce(1,2)]);
PsiProbeInit = zeros(imageSizeReduce);
psi = zeros(imageSizeReduce);
intOutput = zeros(imageSizeReduce);
% Main loops
scale = emdSTEM.interpolationFactor^4;
if flag_keep_beams == 1
    emdSTEM.beamsOutput = zeros( ...
        imageSizeReduce(1),...
        imageSizeReduce(2),...
        length(emdSTEM.beamsIndex));
end


stack_g               = gpuArray(single(emdSTEM.stack));
intOutput_g           = gpuArray(single(intOutput));
psi_g                 = gpuArray(single(psi));
lambda_g              = gpuArray(single(emdSTEM.lambda));
qxaReduce_g           = gpuArray(single(qxaReduce));
qyaReduce_g           = gpuArray(single(qyaReduce));
probeDefocusArray_g   = gpuArray(single(emdSTEM.probeDefocusArray));
probeSemiangleArray_g = gpuArray(single(emdSTEM.probeSemiangleArray));
probeXtiltArray_g     = gpuArray(single(emdSTEM.probeXtiltArray));
probeYtiltArray_g     = gpuArray(single(emdSTEM.probeYtiltArray));
detectorAngles_g      = gpuArray(single(emdSTEM.detectorAngles));
dr_g                  = gpuArray(single(dr));
dq_g                  = gpuArray(single(dq));
% alphaInd_g            = gpuArray(single(emdSTEM.alphaInd));
Ndet_g                = gpuArray(single(Ndet));
PsiProbeInit_g        = gpuArray(single(PsiProbeInit));
xp_g                  = gpuArray(single(emdSTEM.xp));
yp_g                  = gpuArray(single(emdSTEM.yp));
pixelSizeOutput_g     = gpuArray(single(emdSTEM.pixelSizeOutput));
cellDim_g             = gpuArray(single(emdSTEM.cellDim));
imageSizeOutput_g     = gpuArray(single(emdSTEM.imageSizeOutput));
numFP_g               = gpuArray(single(emdSTEM.numFP));
beamsIndex_g          = gpuArray(single(emdSTEM.beamsIndex));
Scompact_g            = gpuArray(single(emdSTEM.Scompact));
xVec_g                = gpuArray(single(xVec));
yVec_g                = gpuArray(single(yVec));
xyBeams_g             = gpuArray(single(xyBeams));
scale_g               = gpuArray(single(scale));
pi_g                  = gpuArray(single(pi));


converter_func        = @gpuArray;


% stack_g               = (single(emdSTEM.stack));
% intOutput_g           = (single(intOutput));
% psi_g                 = (single(psi));
% lambda_g              = (single(emdSTEM.lambda));
% qxaReduce_g           = (single(qxaReduce));
% qyaReduce_g           = (single(qyaReduce));
% probeDefocusArray_g   = (single(emdSTEM.probeDefocusArray));
% probeSemiangleArray_g = (single(emdSTEM.probeSemiangleArray));
% probeXtiltArray_g     = (single(emdSTEM.probeXtiltArray));
% probeYtiltArray_g     = (single(emdSTEM.probeYtiltArray));
% detectorAngles_g      = (single(emdSTEM.detectorAngles));
% dr_g                  = (single(dr));
% dq_g                  = (single(dq));
% % alphaInd_g            = (single(emdSTEM.alphaInd));
% Ndet_g                = (single(Ndet));
% PsiProbeInit_g        = (single(PsiProbeInit));
% xp_g                  = (single(emdSTEM.xp));
% yp_g                  = (single(emdSTEM.yp));
% pixelSizeOutput_g     = (single(emdSTEM.pixelSizeOutput));
% cellDim_g             = (single(emdSTEM.cellDim));
% imageSizeOutput_g     = (single(emdSTEM.imageSizeOutput));
% numFP_g               = (single(emdSTEM.numFP));
% beamsIndex_g          = (single(emdSTEM.beamsIndex));
% Scompact_g            = (single(emdSTEM.Scompact));
% xVec_g                = (single(xVec));
% yVec_g                = (single(yVec));
% xyBeams_g             = (single(xyBeams));
% scale_g               = (single(scale));
% pi_g                  = (single(pi));
% 
% converter_func        = @single;

for a0 = converter_func(1:length(probeDefocusArray_g))
    for a1 = converter_func(1:length(probeSemiangleArray_g))
        qProbeMax_g = probeSemiangleArray_g(a1) / lambda_g;
        
        for a2 = converter_func(1:length(probeXtiltArray_g))
            for a3 = converter_func(1:length(probeYtiltArray_g))
                qxaShift_g = qxaReduce_g  ...
                    -  probeXtiltArray_g(a2) / lambda_g;
                qyaShift_g = qyaReduce_g  ...
                    -  probeYtiltArray_g(a3) / lambda_g;
                q2_g(:) = (qxaShift_g.^2 + qyaShift_g.^2);
                q1_g(:) = sqrt(q2_g);
                
                % Build shifted detector coordinate array
                alphaInd_g = round((q1_g*lambda_g ...
                    - detectorAngles_g(1)) / dr_g) + 1;
                alphaInd_g(alphaInd_g<1) = 1;
                alphaMask_g = alphaInd_g <= Ndet_g;
                alphaInds_g = alphaInd_g(alphaMask_g);
                alphaInd_g(~alphaMask_g) = 0;
                
                % Build unshifted, tilted probed probe with defocus
                PsiProbeInit_g(:) = (erf((qProbeMax_g - q1_g) ...
                    /(0.5*dq_g))*0.5 + 0.5);
                PsiProbeInit_g(:) = PsiProbeInit_g(:) ...
                    .* exp((-1i*pi*lambda_g ...
                    * probeDefocusArray_g(a0))*q2_g');
                PsiProbeInit_g(:) = PsiProbeInit_g(:) ...
                    / sqrt(sum(abs(PsiProbeInit_g(:)).^2));
             
                % Calculate additional probe shift in cut out region to
                % beam tilt, apply in final probe calculation.
                zTotal_g = cellDim_g(3);  % plus defocus shift?
                xTiltShift_g = -zTotal_g ...
                    * tan(probeXtiltArray_g(a2));
                yTiltShift_g = -zTotal_g ...
                    * tan(probeYtiltArray_g(a3));
                
%                 for ax = converter_func(1:length(xp_g))
%                     ax
%                     for ay = converter_func(1:length(yp_g))
                for ax = converter_func(1:25)
                    ax
                    for ay = converter_func(1:25)
                        
                        % Cut out the potential segment
                        x0_g = xp_g(ax)/pixelSizeOutput_g(1);
                        y0_g = yp_g(ay)/pixelSizeOutput_g(2);
                        x_g = mod(xVec_g + round(x0_g),...
                            imageSizeOutput_g(1)) + 1;
                        y_g = mod(yVec_g + round(y0_g),...
                            imageSizeOutput_g(2)) + 1;
                        
                        intOutput_g(:) = 0;
                        for a5 = converter_func(1:numFP_g)
                            % Build signal from beams
                            psi_g(:) = 0;
                            for a4 = converter_func(1:length(beamsIndex_g))
                                xB_g = xyBeams_g(a4,1);
                                yB_g = xyBeams_g(a4,2);
                                if abs(PsiProbeInit_g(xB_g,yB_g)) > 0
                                    q0_g = [qxaReduce_g(xB_g,yB_g) ...
                                        qyaReduce_g(xB_g,yB_g)];
                                    phaseShift_g = exp(-2j*pi_g ...
                                        *(q0_g(1)*(xp_g(ax) + xTiltShift_g) ...
                                        + q0_g(2)*(yp_g(ay) + yTiltShift_g)));
                                    psi_g = psi_g ...
                                        + (PsiProbeInit_g(xB_g,yB_g) * phaseShift_g) ...
                                        * Scompact_g(x_g,y_g,a4);
                                end
                            end
                            
                            intOutput_g = intOutput_g ...
                                + abs(fft2(psi_g)).^2;
                        end
                        
                        % Output signal
                        stack_g(ax,ay,:,a0,a1,a2,a3) = ...
                            stack_g(ax,ay,:,a0,a1,a2,a3) ...
                            + reshape(accumarray(alphaInds_g',...
                            intOutput(alphaMask_g),[Ndet_g 1]),...
                            [1 1 Ndet_g]) * scale_g;
                    end
                    
%                     comp = ((((ax / length(emdSTEM.xp) ...
%                         + a3 - 1) / length(emdSTEM.probeYtiltArray) ...
%                         + a2 - 1) / length(emdSTEM.probeXtiltArray) ...
%                         + a1 - 1) / length(emdSTEM.probeSemiangleArray) ...
%                         + a0 - 1) / length(emdSTEM.probeDefocusArray);
%                     progressbar(comp,2);
                end
            end
        end
    end
end

emdSTEM.stack = gather(stack_g);
% intOutput     = gather(intOutput_g);
% psi           = gather(psi_g);


if flag_plot == true
    figure(1)
    clf
    imagesc(fftshift(abs(fft2(psi)).^0.5))
    axis equal off
    colormap(jet)
    set(gca,'position',[0 0 1 1])
    
    figure(2)
    clf
    amp = abs(psi).^0.5;
    ampRange = [0 1];    
    phase = angle(psi)+pi*0.15;
    [Irgb] = colorComplex(amp/max(amp(:)),phase,ampRange);
    imagesc(Irgb)
    axis equal off
    colormap(jet)
    set(gca,'position',[0 0 1 1])
end

toc
end