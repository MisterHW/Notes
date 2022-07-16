% EXAMPLE / generated file for openEMS from FreeCAD
%
% This is generated file
%
% FreeCAD to OpenEMS plugin by Lubomir Jagos
%

close all
clear
clc

%% switches & options...
postprocessing_only = 0;
draw_3d_pattern = 0; % this may take a while...
use_pml = 1;         % use pml boundaries instead of mur

currDir = strrep(pwd(), '\', '\\');
display(currDir);

%LuboJ, JUST TO SEE RESULT
openEMS_opts = '';

%% setup the simulation
physical_constants;

%% prepare simulation folder
Sim_Path = 'tmp';
Sim_CSX = '002.xml';
[status, message, messageid] = rmdir( Sim_Path, 's' ); % clear previous directory
[status, message, messageid] = mkdir( Sim_Path ); % create empty simulation folder

%% setup FDTD parameter & excitation function
max_timesteps = 100000;
min_decrement = 0.001; % equivalent to -50 dB
FDTD = InitFDTD( 'NrTS', max_timesteps, 'EndCriteria', min_decrement );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MESH variable init
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mesh.x = [];
mesh.y = [];
mesh.z = [];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EXCITATION excitation 1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
f0 = 2.5*1000000000.0;
fc = 2.0*1000000000.0;
FDTD = SetGaussExcite(FDTD, f0, fc );
max_res = c0 / (f0 + fc) / 20;
BC = {"PML_4","PML_4","PML_4","PML_4","PML_4","PML_4"}; % boundary conditions
FDTD = SetBoundaryCond( FDTD, BC );

CSX = InitCSX();

CSX = AddMetal( CSX, 'PEC' );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PORT - electric field - electric field port
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
CSX = AddDump(CSX, 'electric field', 'DumpType', 0, 'DumpMode', 2);
dumpStart = [-2.5, -2.5, 2.0];
dumpStop = [52.5, 52.5, 2.5];
CSX = AddBox(CSX, 'electric field', 0, dumpStart, dumpStop );
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PORT - portIn - Term_IN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
portStart = [0.5, 24.0, 0.0];
portStop = [2.5, 26.0, 2.5];
portR = 50;
portUnits = 1;
portDirection = [0 0 1];
[CSX port{1}] = AddLumpedPort(CSX, 9400, 1, portR*portUnits, portStart, portStop, portDirection, true);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PORT - portOut - Term_OUT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
portStart = [47.5, 24.0, 0.0];
portStop = [49.5, 26.0, 2.5];
portR = 50;
portUnits = 1;
portDirection = [0 0 1];
[CSX port{2}] = AddLumpedPort(CSX, 9500, 2, portR*portUnits, portStart, portStop, portDirection);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MESH - grid_coarse - Air_Volume
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mesh.x = [mesh.x (-9.996666666666666:1.0:59.99666666666667) + 0];
mesh.y = [mesh.y (-9.996666666666666:1.0:59.99666666666667) + 0];
mesh.z = [mesh.z (-4.996666666666667:1.0:14.996666666666666) + 0];
CSX = DefineRectGrid(CSX, 0.001, mesh);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MESH - grid_fine - fine mesh region
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mesh.x = [mesh.x (0.003333333333333333:1.0:49.99666666666667) + 0];
mesh.y = [mesh.y (0.003333333333333333:1.0:49.99666666666667) + 0];
mesh.z = [mesh.z (0.003333333333333333:0.25:2.9966666666666666) + 0];
CSX = DefineRectGrid(CSX, 0.001, mesh);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MATERIAL - FR4
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
CSX = AddMaterial( CSX, 'FR4' );
CSX = SetMaterialProperty( CSX, 'FR4', 'Epsilon', 4.5, 'Kappa', 0.0);
CSX = ImportSTL(CSX, 'FR4',9600, [currDir '/Substrate_gen_model.stl'],'Transform',{'Scale', 1});
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MATERIAL - PEC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
CSX = AddMetal( CSX, 'PEC' );
CSX = ImportSTL(CSX, 'PEC',9800, [currDir '/Top_Conductor_gen_model.stl'],'Transform',{'Scale', 1});
CSX = ImportSTL(CSX, 'PEC',9700, [currDir '/GND_gen_model.stl'],'Transform',{'Scale', 1});
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MATERIAL - air
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
CSX = AddMaterial( CSX, 'air' );
CSX = SetMaterialProperty( CSX, 'air', 'Epsilon', 1, 'Kappa', 0);
CSX = ImportSTL(CSX, 'air',9300, [currDir '/Air_Volume_gen_model.stl'],'Transform',{'Scale', 1});
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRID PRIORITIES GENERATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MESH PRIORITY - grid_fine - fine mesh region
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mesh.x(mesh.x >= 0.003333333333333333 & mesh.x <= 49.99666666666667) = [];
mesh.x = [mesh.x (0.003333333333333333:1.0:49.99666666666667) + 0];
mesh.y(mesh.y >= 0.003333333333333333 & mesh.y <= 49.99666666666667) = [];
mesh.y = [mesh.y (0.003333333333333333:1.0:49.99666666666667) + 0];
mesh.z(mesh.z >= 0.003333333333333333 & mesh.z <= 2.9966666666666666) = [];
mesh.z = [mesh.z (0.003333333333333333:0.25:2.9966666666666666) + 0];

mesh.x = sort(mesh.x);
mesh.y = sort(mesh.y);
mesh.z = sort(mesh.z);
disp(["mesh min spacing x : " num2str(min(abs(diff(mesh.x))))]);
disp(["mesh min spacing y : " num2str(min(abs(diff(mesh.y))))]);
disp(["mesh min spacing z : " num2str(min(abs(diff(mesh.z))))]);

minimumMeshSpacing = 1E-6;
if ((min(abs(diff(mesh.x))) <= minimumMeshSpacing) || 
    (min(abs(diff(mesh.y))) <= minimumMeshSpacing) || 
    (min(abs(diff(mesh.z))) <= minimumMeshSpacing))
  disp("Minimum mesh spacing violated, removing duplicate entries.");
  mesh.x = uniquetol(mesh.x, minimumMeshSpacing);
  mesh.y = uniquetol(mesh.y, minimumMeshSpacing);
  mesh.z = uniquetol(mesh.z, minimumMeshSpacing);
end

CSX = DefineRectGrid(CSX, 0.001, mesh);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NF2FF PROBES GRIDLINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
CSX = DefineRectGrid(CSX, 0.001, mesh);
WriteOpenEMS( [Sim_Path '/' Sim_CSX], FDTD, CSX );
CSXGeomPlot( [Sim_Path '/' Sim_CSX] );

if (postprocessing_only==0)
    %% run openEMS
    RunOpenEMS( Sim_Path, Sim_CSX, openEMS_opts );
end
