%% QniCountour
     fig=[];
       timesteps=[1,3,5,9,18,28,60]; %secs
       Cts=length(timesteps);
       fig=plotContour(Stone,fig,'Stone',1,2);
       ts=1;
       for i=1:Cts
           tt=timesteps(i)*3.638;
           ii=timesteps(i)+10;
           nm=strcat('t=',num2str(round(tt)));
           fig=plotContour(BW{ii},fig,nm,ts+1);
           if ts<Cts,ts=ts+1;end;
       end  
       figure(fig);
       a=get(fig,'CurrentAxes');
       set(a,'YDir','reverse');
       legend('show');
       haxes=get(fig,'CurrentAxes');
       set(haxes,'DataAspectRatioMode','manual');