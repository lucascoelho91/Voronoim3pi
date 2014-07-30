%--------------------------------------------------------------------------
%
% File Name:      readOptitrack.m
% Date Created:   2014/07/09
% Date Modified:  2014/07/10
%
% Author:         Eric Cristofalo
% Contact:        eric.cristofalo@gmail.com
%
% Description:    Obtaining Optitrack data in MATLAB. 
%                 Adpated from Dingjiang Zhou.
%
% Instructions:   Optitrack MUST be running first.
%                 At least one rigid body MUST be created in Optitrack
%                 Optitrack MUST be streaming data:
%                     View -> Streaming Pane
%                     Check 'Broadcast Frame Data'
%                     Under Network Options:
%                         Select 'Multicast' as the Type
%
% Inputs:        opti: Original opti structure
%                frame: 'Optitrack' - Exports position in Optitrack's
%                                     calibration coordinate system 
%                                     (x-z ground plane, y up)
%                        'XY Plane' - Exports position with new  
%                                     plane coordinate system
%                                     (x-y ground plane, z down, angles counterclockwise)
%                       'XYZ+ Plane - Exports position with new  
%                                     plane coordinate system
%                                     (x-y ground plane, z up, angles clockwise)
%
% Outputs:        opti: structure containing all Optitrack output
%                       information
%                 Access position and Euler angles in opti.pose
%                 Raw Optitrack data available in opti.rigidBodies.SE3
%
% Example:        opti = readOptitrack('Euler','XY Plane')
%
%--------------------------------------------------------------------------


%% Function
function opti = readOptitrack(opti,frame)

    % Receive Data
    opti.camIO.Socket.receive(opti.camIO.recv);
    
    % Store in Buffer
    socketData = opti.camIO.recv.getData();
    bufSize    = length(socketData);
    
    % Parse Data
    % opti.rigidBodies.ID may not in the 1,2,3,... sequence, 
    % depending on in what sequence the rigid bodies were created.
    [opti.rigidBodies] = parseNatNetMex(socketData,bufSize);
    
    % Convert Optitrack's Quaternions from YZX to ZYX angles
    % Quaternion variables position changing to have [q0,q1,q2,q3] sequence
    % q2 is set to -q2 to get obtain ZYX angles.
    temp                      = opti.rigidBodies.SE3(7,:); % save q0
    opti.rigidBodies.SE3(7,:) = opti.rigidBodies.SE3(5,:); % q3 done
    opti.rigidBodies.SE3(5,:) = opti.rigidBodies.SE3(4,:); % q1 done
    opti.rigidBodies.SE3(4,:) = temp;                      % q0 done
    opti.rigidBodies.SE3(6,:) = -opti.rigidBodies.SE3(6,:); % q2 = -q2
    
    % Still require an Euler angle transformation to desired frame
    eulerAngleTrans = [1 0 0;0 0 1;0 -1 0];
    
    % frame Case Statements
    switch frame
        case 'Optitrack' % Keep raw position data
            opti.pose(1:3,:) = opti.rigidBodies.SE3(1:3,:);
            
        case 'XY Plane' % Convert to x-y ground plane coordinate system
            transformation = [1 0  0;  % -90 degree rotation about x
                              0 0  1;
                              0 -1 0];
            opti.pose(1:3,:) = ...
                    transformation * opti.rigidBodies.SE3(1:3,:);
            % Convert Euler angles to x-y gound plane frame (90 rotation)
            eulerAngleTrans = eulerAngleTrans*eulerAngleTrans;
        case 'XYZ+ Plane' % Convert to YX plane (x goes from the wall to the water dispenser
                         % y goes from the optitrack computer to the other
                         % side
            transformation1 = [1 0 0;  % 90 degree rotation about x
                              0 0 -1;
                              0 1 0];
            transformation2 = [0 -1 0;  % -90 degree rotation about z 
                               1 0 0;
                               0 0 1];
            transformation = transformation2 * transformation1;
            opti.pose(1:3,:) = ...
                    transformation * opti.rigidBodies.SE3(1:3,:);
            eulerAngleTrans = transformation * transformation * transformation;
    end
    
    % Convert quaternions to Euler angles
    euler = zeros(3,opti.rigidBodyNum);
    for i = 1:opti.rigidBodyNum
        % Calculate Rotation Matrix from Quaternions
        rotationMatrix = quatrn2rot(opti.rigidBodies.SE3(4:7,i));
        euler(:,i) = rot2ZYXeuler(rotationMatrix);
    end
    
    % Assign Euler Angles to Pose
    opti.pose(4:6,:) = eulerAngleTrans*euler;
    
end













