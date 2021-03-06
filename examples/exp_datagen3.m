function exp_datagen3(varargin)
% Yet another example of data generation
% based on exp_datagen2.m The focus is however rather in having various SNR 
% levels. Used for training SQI algorithms.
% 
% Input:
%   path        saving path (default pwd)
%   debug       toggle debug (default true)
%
% Overall information:
%   -  5 feto-maternal combinations
%   -  3 SNR levels (0,3,6,9,12 dB)
%   -  Each dataset with 1,5min duration
%   -  5x repetition for statistical evaluation
%
% Cases/events:
%   - Case 0 - Baseline
%   - Case 1 - fetal and maternal HR abrupt change (by 1/3 using tanh() normally distributed)
%   - Case 2 - SNR abrupt change (by 1/3 using tanh() modulation, amplitude and direction normally distributed)
%   - Case 3 - SNR sinusoidal change (1-10 cycles/recording) modulated by decaying/increasing exponential 
%   - Case 4 - overall ECG amplitude change (sinusoidal 1-10 cycles/recording)
% 
%
% More detailed help is in the <a href="https://fernandoandreotti.github.io/fecgsyn/">FECGSYN website</a>.
%
% Examples:
% exp_datagen3(pwd,5) % generate data and plots
%
% See also:
% exp_datagen1
% exp_datagen2 
% FECGSYNDB_datagen
% 
% --
% fecgsyn toolbox, version 1.2, Jan 2017
% Released under the GNU General Public License
%
% Copyright (C) 2014  Joachim Behar & Fernando Andreotti
% University of Oxford, Intelligent Patient Monitoring Group - Oxford 2014
% joachim.behar@oxfordalumni.org, fernando.andreotti@eng.ox.ac.uk
%
% 
% For more information visit: https://www.physionet.org/physiotools/ipmcode/fecgsyn/
% 
% Referencing this work
%
%   Behar Joachim, Andreotti Fernando, Zaunseder Sebastian, Li Qiao, Oster Julien, Clifford Gari D. 
%   An ECG simulator for generating maternal-foetal activity mixtures on abdominal ECG recordings. 
%   Physiological Measurement.35 1537-1550. 2014.
%
% Last updated : 10-03-2016
% 
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

%% == check inputs
if nargin >2, error('Too many inputs to data generation function'),end
slashchar = char('/'*isunix + '\'*(~isunix));
optargs = {[pwd slashchar] 5};  % default values for input arguments
newVals = cellfun(@(x) ~isempty(x), varargin);
optargs(newVals) = varargin(newVals);
[path,debug] = optargs{:};
if ~strcmp(path(end),slashchar), path = [path slashchar];end

%% Global parameters
paramorig.fs = 1000;            % sampling frequency [Hz]
paramorig.n = 90*paramorig.fs;  % number of data points to generate (5 min)
% electrode positions
x = pi/12*[3 4 5 6 7 8 9 10]' -pi/2;     % 32 abdominal channels
y = .5*ones(8,1);
xy = repmat([x y],4,1);
z = repmat([-.1 -.2 -.3 -.4],8,1); z = reshape(z,32,1);
abdmleads = [xy z];
refs = [-pi/4 0.5 0.4;(5/6-.5)*pi 0.5 0.4];  % + 2 reference leads
paramorig.elpos = [abdmleads;refs];

%% Data generation
cd(path)
for i = 1:5           % generate 5 cases of each
    close all
    paramst = paramorig;
    paramst.fhr = 135+10*randn;   % choosing foetal heart rate
    % mean=135, std= 10 [bpm]
    paramst.mhr = 80+10*randn;    % choosing maternal heart rate
    % mean = 80, std = 10 [bpm]
    
    % setting up stationary mixture
    paramst.mtypeacc = 'nsr';      % force constant mother heart rate
    paramst.ftypeacc = {'nsr'};    % force constant foetal heart rate
    paramst.SNRfm = -9 + randn;
    out = run_ecg_generator(paramst,debug);  % stationary output
    %plotmix(out)
    out = clean_compress(out);
    paramst = out.param;                    % keeping same parameters
    clear out
    % adding some noise
    for SNRmn = 0:3:12 % five noise levels
        for loop = 1:5 % repeat same setup
            % just recalculating noise five times
            % reseting config    outst = out;
            %%% Case 0: Baseline (noise and hearts, no event)
            disp('Case 0')
            tic
            disp(['Generating for SNRmn=' num2str(SNRmn) ' simulation number ' num2str(i) '.'])
            param = paramst;
            param.SNRmn = SNRmn;    % varying SNRmn
            param.ntype = {'MA','MA'}; % noise types
            disp(['Generating for SNRmn=' num2str(SNRmn) ' simulation number ' num2str(i) '.'])
            param = paramst;
            param.SNRfm = -9 + 2*randn;
            param.SNRmn = SNRmn;    % varying SNRmn
            param.ntype = {'MA','MA'}; % noise types
            param.fheart{1} = [pi*(2*rand-1)*sign(randn)/10 (0.1*rand*sign(randn)+0.15) -0.3*rand]; % define first foetus position
            param.noise_fct = {1+.5*randn,1+.5*randn}; % constant SNR (each noise may be modulated by a function)
            param.posdev = 0;   % fixating maternal and foetal hearts for this run
            param.mres = 0.25 + 0.05*randn; % mother respiration frequency
            param.fres = 0.9 + 0.05*randn; % foetus respiration frequency
            parambase = param;              % these parameters are mostly maintained
            out = run_ecg_generator(param,debug);  % stationary output
            out = clean_compress(out); %#ok<*NASGU>
            save([path 'fecgsyn' sprintf('%2.2d_snr%2.2ddB_l%d_c0',i,SNRmn,loop)],'out')
            toc
            clear out
            
            %%% Case 1: rate rate accelerations (both fetal and maternal)
            disp('Case 1')
            tic
            param = parambase;
            param.macc = (20+10*abs(randn))*sign(randn); % maternal acceleration in HR [bpm]
            param.mtypeacc = 'tanh';                % hyperbolic tangent acceleration
            param.maccmean = 2*rand-1;
            param.ftypeacc = {'tanh'};                % hyperbolic tangent acceleration
            param.faccmean{1} = 2*rand-1;
            param.facc = (30 + 10*randn)*sign(randn); % foetal decceleration in HR [bpm]
            out = run_ecg_generator(param,debug);   % stationary output
            out = clean_compress(out);
            out.macc = param.macc;
            save([path 'fecgsyn' sprintf('%2.2d_snr%2.2ddB_l%d_c1',i,SNRmn,loop)],'out')
            toc
            clear out
            
            %%% Case 2: SNR abrupt change
            disp('Case 2')
            tic
            param = parambase;
            param.noise_fct{1} = 1+sign(randn)*(rand+0.3)*tanh(linspace(-rand*pi,(1+rand)*pi,param.n));  % tanh function
            param.noise_fct{2} = param.noise_fct{1};  % tanh function
            param.ntype = {'MA' 'MA'};
            out = run_ecg_generator(param,debug);  % stationary output
            out = clean_compress(out);
            out.noisefcn = param.noise_fct{1};
            save([path 'fecgsyn' sprintf('%2.2d_snr%2.2ddB_l%d_c2',i,SNRmn,loop)],'out')
            toc
            clear out
            
           %%% Case 3: SNR oscilating
            disp('Case 3')
            tic
            param = parambase;
            cyccount = randi([1,10],1,1);
            piinit = (2*rand-1);
            modfun1 = (1+sin(linspace(piinit*pi,cyccount*2*pi+piinit,param.n))*(0.2*rand+0.001)); % sinusoidal
            modfun2 = (rand/2+0.5)*exp(sign(randn).*linspace(0,rand,param.n)); % decaying/increasing exponential
            param.noise_fct{1} = modfun1.*modfun2;  % tanh function
            param.noise_fct{2} = param.noise_fct{1};  % tanh function
            param.ntype = {'MA' 'MA'};
            out = run_ecg_generator(param,debug);  % stationary output
            out = clean_compress(out);
            out.noisefcn = param.noise_fct{1};
            save([path 'fecgsyn' sprintf('%2.2d_snr%2.2ddB_l%d_c3',i,SNRmn,loop)],'out')
            toc
            clear out modfun1 modfun2
            
           %%% Case 4: overall MECG amplitude change (sinusoidal 1-10 cycles/recording)
            disp('Case 4') 
            tic
            param = parambase;
            out = run_ecg_generator(param,debug);  % stationary output
            cyccount = randi([1,10],1,1);
            piinit = (2*rand-1)*pi; % [-pi,pi]
            modfun = (1+sin(linspace(piinit,cyccount*2*pi+piinit,param.n))*(0.2*rand+0.001));
            out.mecg = repmat(modfun,34,1).*out.mecg;
            out = clean_compress(out);
            out.modfun = modfun;
            out.cycles = cyccount;
            save([path 'fecgsyn' sprintf('%2.2d_snr%2.2ddB_l%d_c4',i,SNRmn,loop)],'out') 
            toc
            clear out
         
        end
    end
end
end
% this function eliminates some of the substructures from "out" and
% compresses the variables to int16 for saving disk space
function out=clean_compress(out)
gain = 3000;
out_tmp=rmfield(out,{'f_model' 'm_model' 'vols' 'selvcgm' 'selvcgf'});
out = struct();
out.mecg = int16(round(3000*out_tmp.mecg));
if ~isempty(out_tmp.fecg)
    for i = 1:length(out_tmp.fecg)
        out.fecg{i} = int16(round(3000*out_tmp.fecg{i}));
    end
else
    out.fecg = {};
end
if ~isempty(out_tmp.noise)
    for i = 1:length(out_tmp.noise)
        out.noise{i} = int16(round(gain*out_tmp.noise{i}));
    end
else
    out.noise = {};
end
out.mqrs = out_tmp.mqrs;
out.fqrs = out_tmp.fqrs;
out.param = out_tmp.param;
end