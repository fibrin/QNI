function [f] = ImPlotDistanceVector( Im ,x0,y0,x,y )
% ImPlotDistanceVector( Im ,x0,y0,x,y )
% ImPlotDistanceVector( Im ,M)
% 
global WorkDir ResDir

   if nargin<4
     y=y0(:,2);
     x=y0(:,1);
     y0=x0(:,2);
     x0=x0(:,1); %!!
   end
   
   plotPoi=0;
   if plotPoi
     bd=5;
     x0=x0+bd;y0=y0+bd;
     x=x+bd;y=y+bd;
     f=Implotpoints(Im,'In POIs',[x0 y0],bd);  %OK
   else  
     f=ImageShow(Im,'Displacement vectors',[],[],[],1);
   end  
   dx=-(x0-x);
   dy=-(y0-y); 
   plotarrow(x0,y0,dx,dy,3,1)
end

function plotarrow(x0,y0,dx,dy,f,fa)
   if ~exist('f','var'),f=1;end;
   if ~exist('fa','var'),fa=1;end;
   dx=dx*f;
   dy=dy*f;
   x1=x0+dx;
   y1=y0+dy;
   hold on
   lw=1;
   arr=[12,0,12;-3,0,+3;1 1 1]';
   arr=arr*fa;
   for i=1:length(x0);
     l=sqrt((dx(i))^2+(dy(i))^2);
     c=-dy(i)/l;s=dx(i)/l;
     %c=-0.866;s=-.5;
     m=[c -s 0;s c 0;0 0 1];
     a=arr*m; 
     ax=a(:,2)+x1(i);
     ay=a(:,1)+y1(i);
     %az=a(3,:);
     plot([x0(i) x1(i)],[y0(i) y1(i)],'r','LineWidth',lw);
     %plot(x1(i),y1(i),'r.','LineWidth',lw,'MarkerSize',5 ,'MarkerFaceColor','n');
     patch(ax,ay,'r');
   end   
  hold off
end


function plotarrow2(x0,y0,dx,dy);
   hold on
   q=quiver(x0,y0,dx,dy);
   set(q,'LineWidth',1);
   set(q,'Color','r');
   set(q,'AutoScaleFactor',1);
   set(q,'MaxHeadSize',0.03);
   set(q,'Marker','x');
   set(q,'MarkerEdgeColor','y');
   set(q,'MarkerFaceColor','none');
   set(q,'MarkerSize',6);
   adjust_quiver_arrowhead_size(q,1);
   hold off
end




  function adjust_quiver_arrowhead_size(quivergroup_handle, scaling_factor)
    % Make quiver arrowheads bigger or smaller.
    %
    % adjust_quiver_arrowhead_size(quivergroup_handle, scaling_factor)
    %
    % Example:
    %   h = quiver(1:100, 1:100, randn(100, 100), randn(100, 100));
    %   adjust_quiver_arrowhead_size(h, 1.5);   % Makes all arrowheads 50% bigger.
    %
    % Inputs:
    %   quivergroup_handle      Handle returned by "quiver" command.
    %   scaling_factor          Factor by which to shrink/grow arrowheads.
    %
    % Output: none

    % Kevin J. Delaney
    % December 21, 2011
    % BMT Scientific Marine Services (www.scimar.com)

    if ~exist('quivergroup_handle', 'var')
        help(mfilename);
        return
    end

    if isempty(quivergroup_handle) || any(~ishandle(quivergroup_handle))
        errordlg('Input "quivergroup_handle" is empty or contains invalid handles.', ...
                 mfilename);
        return
    end

    if length(quivergroup_handle) > 1
        errordlg('Expected "quivergroup_handle" to be a single handle.', mfilename);
        return
    end

    if ~strcmpi(get(quivergroup_handle, 'Type'), 'hggroup')
        errrodlg('Input "quivergroup_handle" is not of type "hggroup".', mfilename);
        return
    end

    if ~exist('scaling_factor', 'var') || ...
       isempty(scaling_factor) || ...
       ~isnumeric(scaling_factor)
        errordlg('Input "scaling_factor" is missing, empty or non-numeric.', ...
                 mfilename);
        return
    end

    if length(scaling_factor) > 1
        errordlg('Expected "scaling_factor" to be a scalar.', mfilename);
        return
    end

    if scaling_factor <= 0
        errordlg('"Scaling_factor" should be > 0.', mfilename);
        return
    end

    line_handles = get(quivergroup_handle, 'Children');

    if isempty(line_handles) || (length(line_handles) < 3) || ...
       ~ishandle(line_handles(2)) || ~strcmpi(get(line_handles(2), 'Type'), 'line')
        errordlg('Unable to adjust arrowheads.', mfilename);
        return
    end

    arrowhead_line = line_handles(2);

    XData = get(arrowhead_line, 'XData');
    YData = get(arrowhead_line, 'YData');

    if isempty(XData) || isempty(YData)
        return
    end

    %   Break up XData, YData into triplets separated by NaNs.
    first_nan_index = find(~isnan(XData), 1, 'first');
    last_nan_index  = find(~isnan(XData), 1, 'last');

    for index = first_nan_index : 4 : last_nan_index
        these_indices = index + (0:2);

        if these_indices(end) > length(XData)
            break
        end

        x_triplet = XData(these_indices);
        y_triplet = YData(these_indices);

        if any(isnan(x_triplet)) || any(isnan(y_triplet))
            continue
        end

        %   First pair.
        delta_x = diff(x_triplet(1:2));
        delta_y = diff(y_triplet(1:2));
        x_triplet(1) = x_triplet(2) - (delta_x * scaling_factor);
        y_triplet(1) = y_triplet(2) - (delta_y * scaling_factor);

        %   Second pair.
        delta_x = diff(x_triplet(2:3));
        delta_y = diff(y_triplet(2:3));
        x_triplet(3) = x_triplet(2) + (delta_x * scaling_factor);
        y_triplet(3) = y_triplet(2) + (delta_y * scaling_factor);

        XData(these_indices) = x_triplet;
        YData(these_indices) = y_triplet;
    end

    set(arrowhead_line, 'XData', XData, 'YData', YData);
  end
