function outstr = wfdb2fecgsyn(path,ch)
% function out = wfdb2fecgsyn(path)
% loading FECGSYNDB from WFDB format
% 
% Input:
%  path             complete path for wfdb file, including identifying name
%                   e.g. "/home/user/sub01_snr00dB_l1_c0" (no extension)
% 
%  ch               which channels to load e.g. [1 8 11 14 19 22 25 32]
% 
% Ouput:
%  outstr              structure used by fecgsyn toolbox
% 
% More detailed help is in the <a href="https://fernandoandreotti.github.io/fecgsyn/">FECGSYN website</a>.
%
% Examples:
% TODO
%
% See also:
% fecgsyn2wfdb
% 
% 
% fecgsyn toolbox, version 1.1, March 2016
% Released under the GNU General Public License
%
% Copyright (C) 2014  Joachim Behar & Fernando Andreotti
% Oxford university, Intelligent Patient Monitoring Group - Oxford 2014
% joachim.behar@eng.ox.ac.uk, fernando.andreotti@mailbox.tu-dresden.de
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
% 
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

slashchar = char('/'*isunix + '\'*(~isunix));
fls = dir([path slashchar '*']);
fls = arrayfun(@(x) x.name,fls,'UniformOutput',false);
outstr = struct('mecg',[],'fecg',cell(1,1),'noise',cell(1,1),'mqrs',[],'fqrs',cell(1,1),'param',[]);
% read one header to figure out how many fetal and noise sources are
% present
recordName = fls{find(~cellfun(@isempty,regexp(fls,'.hea')),1)};
fid = fopen(recordName,'r');
formatSp = '%29s%[^\n\r]';
data = textscan(fid, formatSp, 'Delimiter', '', 'WhiteSpace', '',  'ReturnOnError', false);
data = data{1};
fclose(fid);
key   = '#nfetus:';
idx = strfind(data, key);
param.Nfetuses = textscan(data{~cellfun(@isempty,idx)},[key '%d']); % number of fetal signals

key   = '#nnoise:';
idx = strfind(data, key);
param.Nnoise = textscan(data{~cellfun(@isempty,idx)},[key '%d']); % number of noise signals
[~,fs]=wfdbdesc(recordName(1:end-4));
param.fs = fs(1);                        % sampling frequency [Hz]
clear fid data recordName idx key formatSp

annfls = fls(cellfun(@isempty, regexp(fls,'\.dat'))&cellfun(@isempty, regexp(fls,'\.hea')));
datfls = fls(~cellfun(@isempty, regexp(fls,'\.dat')));


outstr.param = param; % more information can be included, case necessary

% loads .dat into outstr structure
for d = 1:length(datfls)
    wfdb2mat(datfls{d}(1:end-4),ch);
    signal = load([datfls{d}(1:end-4) 'm.mat']);
    signal = signal.val';
    delete([datfls{d}(1:end-4) 'm.mat']);
    entry = fliplr(strtok(datfls{d}(end-4:-1:1),'_'));
    if strcmp(entry,'mecg')
        outstr.mecg = signal';
        continue
    end
    for dattype = {'fecg' 'noise'} % these contain subindexes
        if regexp(entry,[dattype{:} '[1-9]'])
            outstr.(entry(1:length(dattype{:}))){str2num(entry(length(dattype{:})+1:end))} ...
                = signal';
        end
    end
end
clear d entry signal datfls dattype

% loads annotations into outstr structure
for a = 1:length(annfls)    
    [recName,ext] = strtok(annfls{a},'.'); ext(1) = [];    
    if strcmp(ext,'mqrs')
        qrs = rdann(recName,'mqrs');   
        outstr.mqrs = qrs';        
    else
        num = regexp(ext, 'fqrs(\d*)', 'tokens');        
        num = str2double(num{1});
        qrs = rdann(recName,ext);   
        outstr.fqrs{num} = qrs';
        
        outstr.fqrs{num} = qrs;
        
    end
end

% If debugging is needed
% plot(outstr.mecg(1,:))
% hold on
% plot(outstr.mqrs,outstr.mecg(1,outstr.mqrs),'or')
% plot(outstr.fecg{1}(1,:))
% plot(outstr.fqrs{1},outstr.fecg{1}(1,outstr.fqrs{1}),'dg')
% hold off

