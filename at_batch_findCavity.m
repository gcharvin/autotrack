function at_batch_findCavity(pos,frames,cavity)
global segmentation

if numel(cavity) & cavity>=0 %track cavities
        segmentation.ROI=[];
        segmentation.ROI.ROI=[];
        segmentation.ROI.x=[];
        segmentation.ROI.y=[];
        segmentation.ROI.theta=[];
        segmentation.ROI.outgrid=[];
              
        for i=frames % loop on frames
            fprintf(['// Cavity tracking - position: ' num2str(pos) ' - frame :' num2str(i) '//\n']);
            
            segmentation.ROI(i).ROI=[];
            segmentation.ROI(i).x=[];
            segmentation.ROI(i).y=[];
            segmentation.ROI(i).theta=[];
            segmentation.ROI(i).outgrid=[];
            
            if i==frames(1)
                fprintf(['Find cavity for the first frame:' num2str(i) '; Be patient...\n']);
                [x y theta ROI ~] = at_cavity(frames(1),'range',70,'rotation',2.5,'npoints',31,'scale',0.2);
                %x=-9.33; y=57.8; theta=0.68;
            end
            
            fprintf(['Fine adjutsment of cavity position\n']); pause(0.01);
            [x y theta ROI ~] = at_cavity(i,'range',30,'rotation',0.2,'npoints',9, 'init',[x y theta],'scale',0.2);
            [x y theta ROI outgrid] = at_cavity(i,'range',10,'npoints',15, 'init',[x y theta],'scale',0.5);%,'grid',grid);
            
            pause(4);
            close
            
            % use moving average over 5 frames to prevent defects in tracking
            if i>frames(1)
                minFrame=max(frames(1),i-5);
                
                xtemp=0; ytemp=0; thetatemp=0;
                ccavg=0;
                
                % x,y,theta
                for m=minFrame:i-1
                    xtemp=xtemp+segmentation.ROI(m).x;
                    ytemp=ytemp+segmentation.ROI(m).y;
                    thetatemp=thetatemp+segmentation.ROI(m).theta;
                    ccavg=ccavg+1;
                end
                
                xtemp=xtemp+x;
                ytemp=ytemp+y;
                thetatemp=thetatemp+theta;
                ccavg=ccavg+1;
                
                xtemp=xtemp/ccavg;
                ytemp=ytemp/ccavg;
                
                thetatemp=thetatemp/ccavg;
                
                [x y theta ROI outgrid] = at_cavity(i,'range',1,'npoints',1, 'init',[xtemp ytemp thetatemp],'scale',1);%,'grid',grid);
            end
            
            % use moving averaging to smoothen cavity motion (in case
            % of errors)
            
            % call at_cavity with one starting point and no iteration
            % to do the smotthing average !
            
            
            if i==frames(1)
                oldROI=ROI;
            else
                oldROI=segmentation.ROI(i-1).ROI;
            end
            
            fprintf(['Map cavity from previous frame\n']); pause(0.01);
            newROI=at_mapROI(ROI,oldROI);
            
            %segmentation.ROI(i).ROI=ROI;
            segmentation.ROI(i).ROI=newROI;
            segmentation.ROI(i).x=x;
            segmentation.ROI(i).y=y;
            segmentation.ROI(i).theta=theta;
            segmentation.ROI(i).outgrid=outgrid;
        end
        
           if numel(cavity)
           % make report for cavity tracking
           cavityTracking(frames)
           end
    end