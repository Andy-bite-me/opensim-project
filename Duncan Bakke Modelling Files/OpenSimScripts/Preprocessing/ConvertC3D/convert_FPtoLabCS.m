function GRFTz_lab = convert_FPtoLabCS(GRFTz_FP, fpInfo)
% Purpose:  Converts Fx, Fy, Fz, Tz, COPx, and COPy from the 
%           FP coordinate systems to the lab coordinate system 
%           for each FP that was hit.
%
% Input:    GRFTz_FP is a structure with the following format,
%             in the FP coordinate systems, sampled at the analog rate:
%               *(fpHitNum) .Fx(nAnalogFrames)
%                           .Fy(nAnalogFrames)
%                           .Fz(nAnalogFrames)
%                           .Tz(nAnalogFrames)
%                           .COPx(nAnalogFrames)
%                           .COPy(nAnalogFrames)
%                           .startIndex - analog frame number indicating
%                                           start of COP, Tz data
%                           .stopIndex  - analog frame number indicating
%                                           end of COP, Tz data
%           fpInfo is a structure that contains the following data:
%               *(fpHitNum) .corners(nCorners, XYZ coordinates, in lab CS)
%                           .origin(XYZ vector from surface to FP origin, 
%                                       in FP CSs)
%
% Output:   GRFTz_lab is a structure with the following format,
%             converted to the lab coordinate system.
%               *(fpHitNum) .Fx(nAnalogFrames)
%                           .Fy(nAnalogFrames)
%                           .Fz(nAnalogFrames)
%                           .Tz(nAnalogFrames)
%                           .COPx(nAnalogFrames)
%                           .COPy(nAnalogFrames)
%                           .startIndex - analog frame number indicating
%                                           start of COP, Tz data
%                           .stopIndex  - analog frame number indicating
%                                           end of COP, Tz data
%
% ASA, 10-05
% 
% NOTE: This code is being saved for use as part of a project
% undertaken by Duncan Bakke at the Auckland Bioengineering Institute.
% The original can be found at
% http://simtk-confluence.stanford.edu:8080/display/OpenSim/Tools+for+Preparing+Motion+Data
% Delp SL, Anderson FC, Arnold AS, Loan P, Habib A, John CT, Guendelman E, Thelen DG. 
% OpenSim: Open-source Software to Create and Analyze Dynamic Simulations of Movement. 
% IEEE Transactions on Biomedical Engineering. (2007) 


% Get number of analog frames in 'simulateable' segment.
nAnalogFrames = length(GRFTz_FP(1).Fx);

% For each forceplate of interest ...
nHits = length(GRFTz_FP);           
for fpHitNum = 1:nHits
        
    % Perform rotation transformations to convert Fx, Fy, Fz, and Tz
    % from the FP CS to the lab CS.
    % NOTE:  X_Lab = X_FP,  Y_Lab = -Y_FP,  Z_Lab = -Z_FP
    
    % DUNCAN:
    % In H20 data, Z_Lab = -Z_FP, Tz_Lab = -Tz_FP
    % and in Force Plate 1: Y_Lab = -Y_FP, X_Lab = X_FP
    % and in Force Plate 2: Y_Lab = X_FP, X_Lab = Y_FP
    % THIS WILL HAVE TO BE CHANGED FOR OTHER PLATES.
    
    if fpHitNum == 2
    GRFTz_lab(fpHitNum).Fx =      GRFTz_FP(fpHitNum).Fx;
    GRFTz_lab(fpHitNum).Fy = -1 * GRFTz_FP(fpHitNum).Fy;
    GRFTz_lab(fpHitNum).Fz = -1 * GRFTz_FP(fpHitNum).Fz;
    GRFTz_lab(fpHitNum).Tz = -1 * GRFTz_FP(fpHitNum).Tz;
    else
    GRFTz_lab(fpHitNum).Fx = -1 * GRFTz_FP(fpHitNum).Fy;
    GRFTz_lab(fpHitNum).Fy = -1 * GRFTz_FP(fpHitNum).Fx;
    GRFTz_lab(fpHitNum).Fz = -1 * GRFTz_FP(fpHitNum).Fz;
    GRFTz_lab(fpHitNum).Tz = -1 * GRFTz_FP(fpHitNum).Tz;
    end
    
    % Initialize arrays for COPx and COPy.
    GRFTz_lab(fpHitNum).COPx = zeros(nAnalogFrames, 1);
    GRFTz_lab(fpHitNum).COPy = zeros(nAnalogFrames, 1);
    
    % Get XYZ coordinates of the FP corners, in the lab CS.
    if fpHitNum == 2
    corner1 = fpInfo(fpHitNum).corners(1, :);
    corner2 = fpInfo(fpHitNum).corners(2, :);
    corner3 = fpInfo(fpHitNum).corners(3, :);
    corner4 = fpInfo(fpHitNum).corners(4, :); 
    else
    corner1 = fpInfo(fpHitNum).corners(1, :);
    corner2 = fpInfo(fpHitNum).corners(2, :);
    corner3 = fpInfo(fpHitNum).corners(3, :);
    corner4 = fpInfo(fpHitNum).corners(4, :); 
    end
    
    % Get position vector from the lab origin to the center of the FP, 
    % in the lab CS; this vector can be calculated from the FP corners.
    pLabToFPcenter_lab = (corner1 + corner2 + corner3 + corner4)/4;

    % Get position vector from the center of the FP surface to the 
    % FP origin, in the FP CS, and convert to the lab CS.
    pFPcenterToFPorigin_FP = fpInfo(fpHitNum).origin;
    pFPcenterToFPorigin_lab = [pFPcenterToFPorigin_FP(1) ...
                               -1 * pFPcenterToFPorigin_FP(2) ...
                               -1 * pFPcenterToFPorigin_FP(3)];
        
    % For each analog frame between startIndex and stopIndex
    % (i.e., the frames for which contact occurs) ...
    for aFrameNum = GRFTz_FP(fpHitNum).startIndex : ...
                        GRFTz_FP(fpHitNum).stopIndex
    
        % Get position vector from the FP origin to the COP, in the FP CS,
        % and convert to the Lab CS.
        pFPoriginToCOP_FP = [GRFTz_FP(fpHitNum).COPx(aFrameNum) ...
                             GRFTz_FP(fpHitNum).COPy(aFrameNum) ...
                             -1*fpInfo(fpHitNum).origin(3)];
        pFPoriginToCOP_lab = [pFPoriginToCOP_FP(1) ...                   
                              -1 * pFPoriginToCOP_FP(2) ...
                              -1 * pFPoriginToCOP_FP(3)];   
    
        % Perform translation transformations to convert COP from the
        % FP CS to the lab CS.
        % DUNCAN:
        % These are specific to the H20 trials, will need alteration
        if fpHitNum == 2
        COP_lab = pLabToFPcenter_lab + ...
              pFPcenterToFPorigin_lab + ...
              pFPoriginToCOP_lab;
        GRFTz_lab(fpHitNum).COPx(aFrameNum) = COP_lab(1);
        GRFTz_lab(fpHitNum).COPy(aFrameNum) = COP_lab(2);
        % Translate Plate 2 by 0.3x, 0.3y
        GRFTz_lab(fpHitNum).COPx(aFrameNum) = GRFTz_lab(fpHitNum).COPx(aFrameNum)-0.3;
        GRFTz_lab(fpHitNum).COPy(aFrameNum) = GRFTz_lab(fpHitNum).COPy(aFrameNum)+0.3;
        else
        COP_lab = pLabToFPcenter_lab + ...
              pFPcenterToFPorigin_lab + ...
              pFPoriginToCOP_lab;
        % Invert x and y on Plate 1
        GRFTz_lab(fpHitNum).COPx(aFrameNum) = COP_lab(2);
        GRFTz_lab(fpHitNum).COPy(aFrameNum) = -COP_lab(1);

        end
    end
    
    % Store startIndex, stopIndex, and FP corners for reference.
    GRFTz_lab(fpHitNum).startIndex = GRFTz_FP(fpHitNum).startIndex;
    GRFTz_lab(fpHitNum).stopIndex = GRFTz_FP(fpHitNum).stopIndex;
end
return;
