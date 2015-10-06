function FECGSYN_exp3results
% this script generates the plots for experiment 3 of the paper
%
% NI-FECG simulator toolbox, version 1.0, February 2014
% Released under the GNU General Public License
%
% Copyright (C) 2014 Joachim Behar & Fernando Andreotti
% Oxford university, Intelligent Patient Monitoring Group - Oxford 2014
% joachim.behar@eng.ox.ac.uk, fernando.andreotti@mailbox.tu-dresden.de
%
% Last updated : 30-05-2014
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% 


%% Auxiliary code to merge multiple result files
% fls = dir('*.mat');     % looking for .mat (creating index)
% fls =  arrayfun(@(x)x.name,fls,'UniformOutput',false);
% morphall = struct('JADEICA',[],'PCA',[],'tsc',[],'tspca',[],'tsekf',[],'alms',[],'arls',[],'aesn',[]);
% for met = {'JADEICA','PCA','tsc','tspca','tsekf','alms','arls','aesn'}
%        morphall.(met{:}) = cell(1750,7);
%  end
% for i = 1:length(fls)
%     load(fls{i})
%     for met = {'JADEICA','PCA','tsc','tspca','tsekf','alms','arls','aesn'}
%         morph.(met{:})(1751:end,:) = [];
%         idx = cellfun(@(x) ~isempty(x),morph.(met{:}));
%         morphall.(met{:})(idx) = morph.(met{:})(idx);
%     end
%         
% end
%                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
%

%% Generating scatter FQT / FTQRS plots
load('/mnt/Data/Andreotti/PhD/Publications/Periodicals/2015.03 Physiol Meas - ICA breaks down/final_results/2015.08.24_results/morphall.mat')
    c0 = cellfun(@(x) ~isempty(regexp(x,'.c0','ONCE')),fls_orig);
    c1 = cellfun(@(x) ~isempty(regexp(x,'.c1','ONCE')),fls_orig);
    c2 = cellfun(@(x) ~isempty(regexp(x,'.c2','ONCE')),fls_orig);
    c3 = cellfun(@(x) ~isempty(regexp(x,'.c3','ONCE')),fls_orig);
    c4 = cellfun(@(x) ~isempty(regexp(x,'.c4','ONCE')),fls_orig);
    c5 = cellfun(@(x) ~isempty(regexp(x,'.c5','ONCE')),fls_orig);
    snr00 = cellfun(@(x) ~isempty(regexp(x,'.snr00dB','ONCE')),fls_orig);
    snr03 = cellfun(@(x) ~isempty(regexp(x,'.snr03dB','ONCE')),fls_orig);
    snr06 = cellfun(@(x) ~isempty(regexp(x,'.snr06dB','ONCE')),fls_orig);
    snr09 = cellfun(@(x) ~isempty(regexp(x,'.snr09dB','ONCE')),fls_orig);
    snr12 = cellfun(@(x) ~isempty(regexp(x,'.snr12dB','ONCE')),fls_orig);
    
    bas = ~(c0|c1|c2|c3|c4|c5);
% % FQT
% colm = [1,2;3,4];
% for row = 1:2;
%     count = 1;
%     figure
% for met = {'JADEICA' 'tsc' 'aesn'}%{'JADEICA' 'PCA' 'tsc' 'tspca' 'tsekf' 'alms' 'arls' 'aesn' }
%     disp(met{:})
%     morphtmp = morphall.(met{:})(bas,:);
%     fqt = morphtmp(:,colm(row,:));
%     for k = 1:size(fqt,1)
%         fqt{k,1}(cellfun(@isempty, fqt{k,1})) = {NaN};
%     end
%     fqtmed = cellfun(@(x) abs(cell2mat(x)),fqt,'UniformOutput',0);
%     fqtmed = cellfun(@(x) nanmedian(x),fqtmed,'UniformOutput',0);
%     fqtmed = [cell2mat(fqtmed(:,1)')' cell2mat(fqtmed(:,2)')'];
%     fqtmed(any(isnan(fqtmed), 2),:)=[];
%     [h,coe]=ttest(fqtmed(:,2),fqtmed(:,1));
%     p.(met{:}) = coe;   
%     if h
%         fprintf('Null hypothesis can be rejected with p= %d \n',p.(met{:}));
%     else
%         fprintf('Null hypothesis CANNOT be rejected');
%     end    
%     % plot
%     subplot(1,3,count)
%     x = fqtmed(:,2); y = fqtmed(:,1);
%     scatter(x,y,12,'filled')
%     % regression
%     a = polyfit(x,y,1);
%     yfit = polyval(a,x);
%     yresid = y - yfit;
%     SSresid = sum(yresid.^2);
%     SStotal = (length(y)-1) * var(y);
%     rsq = 1 - SSresid/SStotal;
%     hold on; plot(x,yfit,'r-'); 
%     if row ==1
%     text(220,140,sprintf('r^2 = %2.4f',rsq))
%     xlim([120,260]),ylim([120,260])
%     xlabel('FQT reference (ms)')
%     ylabel('FQT test (ms)')
%     else
%        text(1,0.2,sprintf('r^2 = %2.4f',rsq))
%         xlim([0 80]),ylim([0 80])
%         xlabel('T/QRS reference (%)')
%         ylabel('T/QRS test (%)')
%     end
%     axis square
% %     title(met{:})
% 
%     count = count +1;
% end
% end
% count = 1;
% for met = {'tsc' 'tsekf'}%{'JADEICA' 'PCA' 'tsc' 'tspca' 'tsekf' 'alms' 'arls' 'aesn' }
%     morphtmp = morphall.(met{:})(bas,:);
%     tqrs = morphtmp(:,colm(2,:));
%     tmed = cellfun(@(x) abs(cell2mat(x)),tqrs,'UniformOutput',0);
%     tmed = cellfun(@(x) nanmedian(x),tmed,'UniformOutput',0);
%     tmed = [cell2mat(tmed(:,1)')' cell2mat(tmed(:,2)')'];
%     tmed(any(isnan(tmed), 2),:)=[];
%     x = tmed(:,2); y = tmed(:,1);  
%     % Bland-Altman plot to show TSekf vs TSc
%     datamean = nanmean([x,y],2);  % Mean of values from each instrument
%     diffmean = nanmean(x-y);               % Mean of difference between instruments
%     diffstd = nanstd(x-y);                % Std dev of difference between instruments   
%     subplot(1,2,count)
%     scatter(datamean,x-y,12,'filled')   % Bland Altman plot
%     hold on,plot(diffmean*ones(1,length(datamean)),'-k')             % Mean difference line
%     plot(diffmean+1.96*diffstd*ones(1,length(datamean)),'--k')                   % Mean plus 2*SD line
%     plot(diffmean-1.96*diffstd*ones(1,length(datamean)),'--k')                  % Mean minus 2*SD line
%     grid on
%     xlabel('mean(T/QRS_{ref},T/QRS_{test})')
%     ylabel('T/QRS_{ref} - T/QRS_{test}')
%     count = count +1;
%     xlim([0 60]),ylim([-40 40]);
% end
%    
%= Case by case methods against each other
% Generate Table

% FQT
counter1 = 1;
stat = zeros(1750,1);
% for met = {'JADEICA' 'PCA' 'tsc' 'tspca' 'tsekf' 'alms' 'arls' 'aesn' }
for met = {'JADEICA' 'tsc' 'aesn' }    
    tmp = morphall.(met{:});
    for i = 1:1750
        tmp{i,1}(cellfun(@isempty, tmp{i,1})) = {NaN};
        stat(i) = nanmedian(abs(nanmedian(cell2mat(tmp{i,1}))-nanmedian(cell2mat(tmp{i,2}))));
    end
    statscase = [stat(bas,1) stat(c0,1) stat(c1,1) stat(c2,1) stat(c3,1) stat(c4,1) stat(c5,1)];
    statnoise.(met{:}).qt = [stat(snr12,1) stat(snr09,1) stat(snr06,1) stat(snr03,1) stat(snr00,1)];
    auxtab = [nanmean(statscase)',-1.*ones(7,1),nanstd(statscase)',-2.*ones(7,1)];
    table(counter1,:) = reshape(auxtab',1,7*4);
%     subplot(2,4,counter1)
%     boxplot(statnoise,{});   
    counter1 = counter1 + 1;
end

% FTh
figure
counter1 = 1;

% for met = {'JADEICA' 'PCA' 'tsc' 'tspca' 'tsekf' 'alms' 'arls' 'aesn' }
for met = {'JADEICA' 'tsc' 'aesn' }    
    tmp = morphall.(met{:});
    for i = 1:1750
       tmp{i,3}(cellfun(@isempty, tmp{i,3})) = {NaN};
       stat(i) = nanmedian(abs(nanmedian(abs(cell2mat(tmp{i,3})))-nanmedian(abs(cell2mat(tmp{i,4})))));
    end
    statscase = [stat(bas,1) stat(c0,1) stat(c1,1) stat(c2,1) stat(c3,1) stat(c4,1) stat(c5,1)];
    auxtab = [nanmean(statscase)',-1.*ones(7,1),nanstd(statscase)',-2.*ones(7,1)];
    table(counter1,:) = reshape(auxtab',1,7*4);
    statnoise.(met{:}).ftqrs = [stat(snr12&c0,1) stat(snr09&c0,1) stat(snr06&c0,1) stat(snr03&c0,1) stat(snr00&c0,1)];
%     subplot(2,4,counter1)
%     boxplot(statnoise,{});   
    counter1 = counter1 + 1;
end

% SNR Plots
qt = []; ftqrs = [];
for i = 1:5 % go through snr
    for met = {'JADEICA' 'tsc' 'aesn' }    
        qt = [qt statnoise.(met{:}).qt(:,i)];
        ftqrs = [ftqrs statnoise.(met{:}).ftqrs(:,i)];  
    end
end

boxplot(qt,{repmat({'snr12dB' 'snr09dB' 'snr06dB' 'snr03dB' 'snr00dB'}',3,1) repmat({'ICA' 'TSc' 'ESN'}',5,1)}, 'factorgap',10)
grid on
figure
boxplot(ftqrs,{repmat({'snr12dB' 'snr09dB' 'snr06dB' 'snr03dB' 'snr00dB'}',3,1) repmat({'ICA' 'TSc' 'ESN'}',5,1)}, 'factorgap',10)
grid on

disp('Done.')

 