 classdef Robot3D 
    properties (SetAccess = 'immutable')
        BASE_HEIGHT = 20;
        LINK_1 = 20;
        LINK_2 = 6.5
        LINK_3 = 20;
    end
    
    methods
        function result = translation_x(robot, x)
            result = [1,0,0,x;
                      0,1,0,0;
                      0,0,1,0;
                      0,0,0,1];
        end
        
        function result = translation_y(robot, y)
            result = [1,0,0,0;
                      0,1,0,y;
                      0,0,1,0;
                      0,0,0,1];
        end
        
        function result = translation_z(robot, z)
            result = [1,0,0,0;
                      0,1,0,0;
                      0,0,1,z;
                      0,0,0,1];
        end
        
        function result = rotation_x(robot, theta)
            result = [1,0,0,0;
                      0,cos(theta),-sin(theta),0;
                      0,sin(theta),cos(theta),0;
                      0,0,0,1];
        end
        
        function result = rotation_y(robot, theta)
            result = [cos(theta),0,sin(theta),0;
                      0,1,0,0;
                      -sin(theta),0,cos(theta),0;
                      0,0,0,1];
        end
        
        function result = rotation_z(robot, theta)
            result = [cos(theta),-sin(theta),0,0;
                      sin(theta),cos(theta),0,0;
                      0,0,1,0;
                      0,0,0,1];
        end

        function frames = forward_kinematics(robot, thetas)
            frames = zeros(4,4,4);
            
            theta = thetas(1);
            frames(:,:,1) = robot.rotation_z(theta);
            
            theta = thetas(2);
            frames(:,:,2) = frames(:,:,1) * robot.translation_z(robot.BASE_HEIGHT) * robot.rotation_y(theta) ;
            
            theta = thetas(3);
            frames(:,:,3) = frames(:,:,2) * robot.translation_z(robot.LINK_1) * robot.translation_x(robot.LINK_2) * robot.rotation_y(theta);
            
            frames(:,:,4) = frames(:,:,3) * robot.translation_x(robot.LINK_3);
        end
        
        function goal_angles = numerical_IK(robot, goal_position, initial_theta)
            function err = my_error_function(theta)   
              actual_position = robot.end_effector(theta);
              err = (goal_position - actual_position).^2;
              err = sum(err);
            end
           
            % Actually run the optimization to generate the angles to get us (close) to
            % the goal.
            % Set joint limit for better performance
            lb = [-pi/2, 0, -pi/2];
            ub = [pi/2, pi/2, pi/2];
            
            %Final goal_angles
            goal_angles = fmincon( @ my_error_function,initial_theta,[],[],[],[],lb,ub);
            goal_angles = wrapToPi(goal_angles);
        end

        %% Shorthand for returning the forward kinematics.
        function fk = fk(robot, thetas)
            fk = robot.forward_kinematics(thetas);
        end
       
        % Returns [x; y; theta] for the end effector given a set of joint
        % angles. 
        function ee = end_effector(robot, thetas)
            % Find the transform to the end-effector frame.
            frames = robot.fk(thetas);
            H_0_ee = frames(:,:,end);
            
            % Extract the components of the end_effector position and
            % orientation.
            x = H_0_ee(1,4);
            y = H_0_ee(2,4);
            z = H_0_ee(3,4);
            % Pack them up nicely.
            ee = [x; y; z];
        end
       
        %% Shorthand for returning the end effector position and orientation. 
        function ee = ee(robot, thetas)
            ee = robot.end_effector(thetas);
        end
    end
 end