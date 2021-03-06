function [X,Y,Pressure,Density,Vx,Vy,Points,time,Tracers,TracerNames,Stickers,StickerNames,Appendices,AppendixNames,NumberOfPointsInCell,Faces,Vertices]=read_hdf(filename,ShouldPlot,WhatToPlot,LogScale,edgestrength,tracernametoplot)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Matlab script to read RICH binary files in float/double format
%
%   Inputs  : filename - The location of the binary file
%             ShouldPlot - 2: indicates to the current figure, 1: indicates
%             that a new figure is wanted 0: no plot
%             WhatToPlot - 1: density, 2: pressure, 3: pressure/density, 4:
%               Entropy (assuming gamma=5/3), 5: Tracer, 6: Appendix
%             LogScale - 1 Plot Log scaled, 0 linear scale
%             edgestrength - The intensity of line edges around each
%               voronoi cell. Values are from 0 to 1 with 1 being very strong
%               edges and 0 no edges.
%             tracernametoplot - Name of tracer or appendix to plot
%   Output  : X - The mesh points
%             Pressure - The pressure
%             Density - The density
%             Vx - The x component of the velocity
%             Vy - The y component of the velocity
%             Points - The vertices of the Voronoi cell
%             time - The time of the simulation
%             Tracers - The scalar tracers
%             TracerNames - The names of the tracers
%             Stickers - The stickers per cell
%             StickerNames - The names of the stickers
%             NumberOfPointsInCell - The number of vertices in each Voronoi
%             cell
%   Example : [X,Pressure,Density,Points,xVelocity,yVelocity,time,Tracers,NumberOfPointsInCell]=read_hdf("output.bin",1,1,1)
%               Plots a log scaled density plot from the file "output.bin"
%             [X,Pressure,Density,Points,xVelocity,yVelocity,time,Tracers,NumberOfPointsInCell]=read_hdf("output.bin",0)
%               Only reads the data from "output.bin"
%             [X,Pressure,Density,Points,xVelocity,yVelocity,time,Tracers,NumberOfPointsInCell]=read_hdf("output.bin")
%               Only reads the data from "output.bin"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(nargin==1),
    ShouldPlot=0;
    WhatToPlot=1;
    LogScale=0;
    edgestrength=0;
    tracernametoplot=0;
elseif (nargin==2),
    ShouldPlot=0;
    WhatToPlot=1;
    LogScale=0;
    edgestrength=0;
    tracernametoplot=0;
elseif (nargin==3),
    LogScale=0;
    edgestrength=0;
    tracernametoplot=0;
elseif (nargin==4),
    edgestrength=0;
    tracernametoplot=0;
elseif (nargin==5),
    tracernametoplot=0;
elseif (nargin==6),
    % do nothing
else
    error('Illegal number of input arguments');
end

h=h5info(filename);

% Read the HDF5 data
Density=h5read(filename,'/hydrodynamic/density');
Pressure=h5read(filename,'/hydrodynamic/pressure');
X=h5read(filename,'/geometry/x_coordinate');
Y=h5read(filename,'/geometry/y_coordinate');
Vx=h5read(filename,'/hydrodynamic/x_velocity');
Vy=h5read(filename,'/hydrodynamic/y_velocity');
time=h5read(filename,'/time');
for i=1:length(h.Groups)
    if(strcmp(h.Groups(i).Name,'/tracers')==1)
        tracerindex=i;
        break;
    end
end
for i=1:length(h.Groups)
    if(strcmp(h.Groups(i).Name,'/appendices')==1)
        appendindex=i;
        break;
    end
end
for i=1:length(h.Groups)
    if(strcmp(h.Groups(i).Name,'/stickers')==1)
        stickerindex=i;
        break;
    end
end
NumberOfStickers=length(h.Groups(stickerindex).Datasets);
NumberOfTracers=length(h.Groups(tracerindex).Datasets);
NumberOfAppendices=length(h.Groups(appendindex).Datasets);
NumberOfCells=length(Density);
Vertx=h5read(filename,'/geometry/x_vertices');
Verty=h5read(filename,'/geometry/y_vertices');
nVert=h5read(filename,'/geometry/n_vertices');
Tracers=zeros(NumberOfCells,NumberOfTracers);
Stickers=zeros(NumberOfCells,NumberOfStickers);
Appendices=zeros(NumberOfCells,NumberOfAppendices);

TracerNames=cell(NumberOfTracers,1);
StickerNames=cell(NumberOfStickers,1);
AppendixNames=cell(NumberOfAppendices,1);
for i=1:NumberOfTracers
    TracerNames{i}= h.Groups(tracerindex).Datasets(i).Name;
end

for i=1:NumberOfTracers
    Tracers(:,i)=h5read(filename,sprintf('/tracers/%s', h.Groups(tracerindex).Datasets(i).Name));
end

for i=1:NumberOfStickers
    StickerNames{i}= h.Groups(stickerindex).Datasets(i).Name;
end

for i=1:NumberOfStickers
    Stickers(:,i)=h5read(filename,sprintf('/stickers/%s', h.Groups(stickerindex).Datasets(i).Name));
end

for i=1:NumberOfAppendices
    AppendixNames{i}= h.Groups(appendindex).Datasets(i).Name;
end

for i=1:NumberOfAppendices
    Appendices(:,i)=h5read(filename,sprintf('/appendices/%s', h.Groups(appendindex).Datasets(i).Name));
end

draw=WhatToPlot;
Log=LogScale;
Temperature=Pressure./Density;
maxfaces=max(nVert);
if(maxfaces>20)
    display('Warning, max number of faces exceeds 20!!')
end

if(ShouldPlot==1||ShouldPlot==2)
    Vertices=zeros(maxfaces*NumberOfCells,2);
    Faces=zeros(maxfaces,NumberOfCells);
end
NumberOfPointsInCell=zeros(NumberOfCells,1);
Points=zeros(NumberOfCells,maxfaces,2);
TotalVertices=1;
for i=1:NumberOfCells
    n=nVert(i);
    if(ShouldPlot==1||ShouldPlot==2)
        Vertices((i-1)*maxfaces+1:(i-1)*maxfaces+n,1)=Vertx(TotalVertices:TotalVertices+n-1);
        Vertices((i-1)*maxfaces+1:(i-1)*maxfaces+n,2)=Verty(TotalVertices:TotalVertices+n-1);
        Faces(1:n,i)=((i-1)*maxfaces+1):((i-1)*maxfaces+n);
        Faces(n+1:maxfaces,i)=NaN;
    end
    Points(i,1:n,1)=Vertx(TotalVertices:TotalVertices+n-1);
    Points(i,1:n,2)=Verty(TotalVertices:TotalVertices+n-1);
    NumberOfPointsInCell(i)=n;
    TotalVertices=TotalVertices+n;
end

if(ShouldPlot==1||ShouldPlot==2)
    if(ShouldPlot==1)
        f1=figure;
        set(f1,'Units','normalized')
        set(f1, 'Position', [0.03 0.03 0.65 0.85])
    end
    colorbar;
    axis equal;
    maxindex=length(Density);
    maxdraw=0;
    switch (draw)
        case 1
            if(Log==1)
                caxis([min(log10(Density)) max(log10(Density*1.01))]);
                patch('Faces',Faces(:,(i-1)*maxdraw+1:maxindex)','Vertices',Vertices,'FaceVertexCData',log10(Density((i-1)*maxdraw+1:maxindex)),'FaceColor','flat','EdgeAlpha',edgestrength);
            else
                caxis([min(Density) max(Density)*1.01]);
                patch('Faces',Faces(:,(i-1)*maxdraw+1:maxindex)','Vertices',Vertices,'FaceVertexCData',Density((i-1)*maxdraw+1:maxindex),'FaceColor','flat','EdgeAlpha',edgestrength);
            end
        case 2
            if(Log==1)
                caxis([min(log10(Pressure)) max(log10(Pressure*1.01))]);
                patch('Faces',Faces(:,(i-1)*maxdraw+1:maxindex)','Vertices',Vertices,'FaceVertexCData',log10(Pressure((i-1)*maxdraw+1:maxindex)),'FaceColor','flat','EdgeAlpha',edgestrength);
            else
                caxis([min(Pressure) max(Pressure)*1.01]);
                patch('Faces',Faces(:,(i-1)*maxdraw+1:maxindex)','Vertices',Vertices,'FaceVertexCData',Pressure((i-1)*maxdraw+1:maxindex),'FaceColor','flat','EdgeAlpha',edgestrength);
            end
        case 3
            if(Log==1)
                caxis([min(log10(Temperature)) max(log10(Temperature*1.01))]);
                patch('Faces',Faces(:,(i-1)*maxdraw+1:maxindex)','Vertices',Vertices,'FaceVertexCData',log10(Temperature((i-1)*maxdraw+1:maxindex)),'FaceColor','flat','EdgeAlpha',edgestrength);
            else
                caxis([min(Temperature) max(Temperature)*1.01]);
                patch('Faces',Faces(:,(i-1)*maxdraw+1:maxindex)','Vertices',Vertices,'FaceVertexCData',Temperature((i-1)*maxdraw+1:maxindex),'FaceColor','flat','EdgeAlpha',edgestrength);
            end
        case 4
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Change here gamma as needed
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            gamma=5/3;
            Entropy=Pressure./Density.^gamma;
            if(Log==1)
                caxis([min(log10(Entropy)) max(log10(Entropy*1.01))]);
                patch('Faces',Faces(:,(i-1)*maxdraw+1:maxindex)','Vertices',Vertices,'FaceVertexCData',log10(Entropy((i-1)*maxdraw+1:maxindex)),'FaceColor','flat','EdgeAlpha',edgestrength);
            else
                caxis([min(Entropy) max(Entropy)*1.01]);
                patch('Faces',Faces(:,(i-1)*maxdraw+1:maxindex)','Vertices',Vertices,'FaceVertexCData',Entropy((i-1)*maxdraw+1:maxindex),'FaceColor','flat','EdgeAlpha',edgestrength);
            end
        case 5
            if(tracernametoplot==0)
                error('No tracer name given');
            end
            tracerindex=find(strcmp(TracerNames,tracernametoplot));
            if(isempty(tracerindex))
                error('No tracer with given name');
            end
            if(Log==1)
                caxis([min(log10(Tracers(:,tracerindex))) max(log10(Tracers(:,tracerindex)*1.01))]);
                patch('Faces',Faces(:,(i-1)*maxdraw+1:maxindex)','Vertices',Vertices,'FaceVertexCData',log10(Tracers((i-1)*maxdraw+1:maxindex,tracerindex)),'FaceColor','flat','EdgeAlpha',edgestrength);
            else
                caxis([min((Tracers(:,tracerindex))) max((Tracers(:,tracerindex)*1.01))]);
                patch('Faces',Faces(:,(i-1)*maxdraw+1:maxindex)','Vertices',Vertices,'FaceVertexCData',Tracers((i-1)*maxdraw+1:maxindex,tracerindex),'FaceColor','flat','EdgeAlpha',edgestrength);
            end
        case 6
            if(tracernametoplot==0)
                error('No appendix name given');
            end
            tracerindex=find(strcmp(AppendixNames,tracernametoplot));
            if(isempty(tracerindex))
                error('No appendix with given name');
            end
            if(Log==1)
                caxis([min(log10(Appendices(:,tracerindex))) max(log10(Appendices(:,tracerindex)*1.01))]);
                patch('Faces',Faces(:,(i-1)*maxdraw+1:maxindex)','Vertices',Vertices,'FaceVertexCData',log10(Appendices((i-1)*maxdraw+1:maxindex,tracerindex)),'FaceColor','flat','EdgeAlpha',0);
            else
                caxis([min((Appendices(:,tracerindex))) max((Appendices(:,tracerindex)*1.01))]);
                patch('Faces',Faces(:,(i-1)*maxdraw+1:maxindex)','Vertices',Vertices,'FaceVertexCData',Appendices((i-1)*maxdraw+1:maxindex,tracerindex),'FaceColor','flat','EdgeAlpha',0.05);
            end
    end
end
