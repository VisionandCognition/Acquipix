% default options are in parenthesis after the comment
clear all;
%sites
cellRec{1}{1} = 'P:\Montijn\DataNeuropixels\Exp2019-11-20\20191120_MP2_RunDriftingGratingsR01_g0';
cellRec{1}{2} = 'P:\Montijn\DataNeuropixels\Exp2019-11-21\20191121_MP2_RunDriftingGratingsR01_g0';
cellRec{1}{3} = 'P:\Montijn\DataNeuropixels\Exp2019-11-22\20191122_MP2_RunDriftingGratingsR01_g0';
cellRec{1}{4} = 'P:\Montijn\DataNeuropixels\Exp2019-11-22\20191122_MP2_R02_RunDriftingGratingsR01_g0';
cellRec{2}{1} = 'P:\Montijn\DataNeuropixels\Exp2019-12-10\20191210_MP3_RunDriftingGratingsR01_g0';%(might have missed onset first stim with eye tracker)
cellRec{2}{2} = 'P:\Montijn\DataNeuropixels\Exp2019-12-11\20191211_MP3_RunDriftingGratingsR01_g0';
cellRec{2}{3} = 'P:\Montijn\DataNeuropixels\Exp2019-12-12\20191212_MP3_RunNaturalMovieR01_g0';
cellRec{2}{4} = 'P:\Montijn\DataNeuropixels\Exp2019-12-13\20191213_MP3_RunDriftingGratingsR01_g0';
cellRec{2}{5} = 'P:\Montijn\DataNeuropixels\Exp2019-12-16\20191216_MP3_RunNaturalMovieR01_g0';
cellRec{2}{6} = 'P:\Montijn\DataNeuropixels\Exp2019-12-17\20191217_MP3_RunDriftingGratingsR01_g0';
cellRec{3}{1} = 'P:\Montijn\DataNeuropixels\Exp2020-01-15\20200115_MP4_RunDriftingGratingsR01_g0';%eye-tracking bad at end
cellRec{3}{2} = 'P:\Montijn\DataNeuropixels\Exp2020-01-16\20200116_MP4_RunDriftingGratingsR01_g0';
cellRec{3}{3} = 'P:\Montijn\DataNeuropixels\Exp2020-01-16\20200116_MP4_RunDriftingGratingsR02_g0';


cellDepthCorrection{1}{1} = 100;%01
cellDepthCorrection{1}{2} = 10;%02, V1
cellDepthCorrection{1}{3} = 10;%03
cellDepthCorrection{1}{4} = 0;%04, NOT DONE
cellDepthCorrection{2}{1} = -600;%05
cellDepthCorrection{2}{2} = -350;%06, V1
cellDepthCorrection{2}{3} = -200;%07
cellDepthCorrection{2}{4} = -50;%08
cellDepthCorrection{2}{5} = -250;%09
cellDepthCorrection{2}{6} = -50;%10
cellDepthCorrection{3}{1} = 200;%11
cellDepthCorrection{3}{2} = 10;%12
cellDepthCorrection{3}{3} = 10;%13

cellDepths{1}{1} = 2650;
cellDepths{1}{2} = 3000;
cellDepths{1}{3} = 3000;
cellDepths{1}{4} = 3500;
cellDepths{2}{1} = 3000;
cellDepths{2}{2} = 3000;
cellDepths{2}{3} = 3000;
cellDepths{2}{4} = 3250;
cellDepths{2}{5} = 3300;
cellDepths{2}{6} = 3500;
cellDepths{3}{1} = 3250;
cellDepths{3}{2} = 3400;
cellDepths{3}{3} = 3300;

cellDepths = cellfun(@plus,cellDepths,cellDepthCorrection);

cellMouseType{1}{1} = 'BL6';
cellMouseType{1}{2} = 'BL6';
cellMouseType{1}{3} = 'BL6';
cellMouseType{1}{4} = 'BL6';
cellMouseType{2}{1} = 'BL6';
cellMouseType{2}{2} = 'BL6';
cellMouseType{2}{3} = 'BL6';
cellMouseType{2}{4} = 'BL6';
cellMouseType{2}{5} = 'BL6';
cellMouseType{2}{6} = 'BL6';
cellMouseType{3}{1} = 'BL6';
cellMouseType{3}{2} = 'BL6';
cellMouseType{3}{3} = 'BL6';

matRunPrePro = [...
	1 1;...1
	1 2;...2
	1 3;...3
	1 4;...4
	2 1;...5
	2 2;...6
	2 3;...7
	2 4;...8
	2 5;...9
	2 6;...10
	3 1;...11
	3 2;...12
	3 3];%13

boolOnlyJson = false;

for intRunPrePro=[10]
	%% prepare
	% clear variables and select session to preprocess
	clearvars -except cellRec cellDepths cellMouseType matRunPrePro intRunPrePro boolOnlyJson
	vecRunPreProGLX = matRunPrePro(intRunPrePro,:);
	fprintf('\nStarting pre-processing of "%s" [%s]\n',cellRec{vecRunPreProGLX(1)}{vecRunPreProGLX(2)},getTime);
	
	%% set recording
	cellPath = strsplit(cellRec{vecRunPreProGLX(1)}{vecRunPreProGLX(2)},filesep);
	cellRecParts = strsplit(cellPath{end},'_');
	strMouse = cellRecParts{2};
	strExperiment = cellPath{4};
	strRecording = cellPath{end};
	strRecIdx = strcat('S',num2str(vecRunPreProGLX(1)),'L',num2str(vecRunPreProGLX(2))); %subject / location
	dblInvertLeads = true; %is ch1 deepest?
	dblCh1DepthFromPia = cellDepths{vecRunPreProGLX(1)}{vecRunPreProGLX(2)};
	strMouseType = cellMouseType{vecRunPreProGLX(1)}{vecRunPreProGLX(2)};
	
	% search for file
	strThisMouseIdx = getFlankedBy(strRecording,'_M','_','last');
	strThisRecIdx = getFlankedBy(strRecording,'R','_','last');
	if intRunPrePro == 4
		strThisRecIdx = getFlankedBy(strRecording,'_R','_','first');
		intLastPupilStop = 5;
	else
		intLastPupilStop = 1;
	end
	if vecRunPreProGLX(1) < 2
		strRec = ['*' strThisMouseIdx '*R' strThisRecIdx '*'];
	else
		strRec = ['*R' strThisRecIdx '*' strThisMouseIdx '*'];
	end

	%% set & generate paths
	strThisPath = mfilename('fullpath');
	strThisPath = strThisPath(1:(end-numel(mfilename)));
	strDataPath = strjoin(cellPath(1:3),filesep);
	strPathDataTarget = ['P:\Montijn\DataPreProcessed' filesep strExperiment filesep];
	if ~exist(strPathDataTarget,'dir'),mkdir(strPathDataTarget);end
	strChanMapFile = strcat(strThisPath,'subfunctionsPP\neuropixPhase3B2_kilosortChanMap.mat');
	strPathStimLogs = fullfile(strDataPath,strExperiment,strMouse);
	strPathEphys = fullfile(strDataPath,strExperiment,strRecording);
	strPathEyeTracking = fullfile(strDataPath,strExperiment,'EyeTracking');
	fprintf('Processing recording at %s [%s]\n',strPathEphys,getTime);
	
	%% load eye-tracking
	%find video file
	fprintf('Loading pre-processed eye-tracking data at %s [%s]\n',strPathEyeTracking,getTime);
	strSearchEyeFile = ['EyeTrackingProcessed*' strrep(strExperiment,'Exp','') strRec '.mat'];
	sEyeFiles = dir(fullfile(strPathEyeTracking,strSearchEyeFile));
	if numel(sEyeFiles) == 1
		sEyeTracking = load(fullfile(sEyeFiles(1).folder,sEyeFiles(1).name));
		sPupil = sEyeTracking.sPupil;
		clear sEyeTracking;
	else
		error([mfilename ':AmbiguousInput'],'Multiple video files found, please narrow search parameters');
	end
	
	% interpolate detection failures
	%initial roundness check
	indWrongA = sqrt(zscore(sPupil.vecPupilCenterX).^2 + zscore(sPupil.vecPupilCenterY).^2) > 4;
	indWrong1 = conv(indWrongA,ones(1,5),'same')>0;
	vecAllPoints1 = 1:numel(indWrong1);
	vecGoodPoints1 = find(~indWrong1);
	vecTempX = interp1(vecGoodPoints1,sPupil.vecPupilCenterX(~indWrong1),vecAllPoints1);
	vecTempY = interp1(vecGoodPoints1,sPupil.vecPupilCenterY(~indWrong1),vecAllPoints1);
	%remove position outliers
	indWrongB = abs(nanzscore(vecTempX)) > 4 | abs(nanzscore(vecTempY)) > 4;
	%define final removal vector
	indWrong = conv(indWrongA | indWrongB,ones(1,5),'same')>0;
	vecAllPoints = 1:numel(indWrong);
	vecGoodPoints = find(~indWrong);
	
	%fix
	sPupil.vecPupilFixedCenterX = interp1(vecGoodPoints,sPupil.vecPupilCenterX(~indWrong),vecAllPoints,'linear','extrap');
	sPupil.vecPupilFixedCenterY = interp1(vecGoodPoints,sPupil.vecPupilCenterY(~indWrong),vecAllPoints,'linear','extrap');
	sPupil.vecPupilFixedRadius = interp1(vecGoodPoints,sPupil.vecPupilRadius(~indWrong),vecAllPoints,'linear','extrap');
	
	% plot
	close;
	figure
	subplot(2,1,1)
	plot(sPupil.vecPupilTime,sPupil.vecPupilCenterX);
	hold on
	plot(sPupil.vecPupilTime,sPupil.vecPupilFixedCenterX);
	hold off
	title(sprintf('Pupil pos x, %s',[strExperiment strRecIdx]),'Interpreter','none');
	xlabel('Time (s)');
	ylabel('Pupil x-position');
	fixfig
	
	subplot(2,1,2)
	plot(sPupil.vecPupilTime,sPupil.vecPupilCenterY);
	hold on
	plot(sPupil.vecPupilTime,sPupil.vecPupilFixedCenterY);
	hold off
	title(sprintf('Pupil pos y, %s',[strExperiment strRecIdx]),'Interpreter','none');
	xlabel('Time (s)');
	ylabel('Pupil y-position');
	fixfig
	drawnow;
	
	%% load NI sync stream times
	strFileNI = strcat(strRecording,'_t0.nidq.bin');
	fprintf('Loading syncing data %s [%s]\n',strFileNI,getTime);
	% Parse the corresponding metafile
	sMetaNI = DP_ReadMeta(strFileNI, strPathEphys);
	dblSampRateReportedNI = DP_SampRate(sMetaNI);
	intFirstSample = str2double(sMetaNI.firstSample);
	
	% Get NI data
	matDataNI = -DP_ReadBin(-inf, inf, sMetaNI, strFileNI, strPathEphys);
	[boolVecScreenPhotoDiode,dblCritValPD] = DP_GetUpDown(matDataNI(1,:));
	[boolVecSyncPulses,dblCritValSP] = DP_GetUpDown(matDataNI(2,:));
	clear matDataNI;
	
	vecChangeScreenPD = diff(boolVecScreenPhotoDiode);
	vecStimOnScreenPD = (find(vecChangeScreenPD == 1)+1);
	vecStimOffScreenPD = (find(vecChangeScreenPD == -1)+1);
	clear vecChangeScreenPD boolVecScreenPhotoDiode;
	
	vecChangeSyncPulses = diff(boolVecSyncPulses);
	vecSyncPulseOn = (find(vecChangeSyncPulses == 1)+1);
	vecSyncPulseOff = (find(vecChangeSyncPulses == -1)+1);
	clear vecChangeSyncPulses boolVecSyncPulses;
	dblSampRateNI = mean(diff(vecSyncPulseOn));
	dblSampRateFault = (1-(dblSampRateReportedNI/dblSampRateNI));
	if dblSampRateFault < -1e-5 || dblSampRateFault > 1e-5
		error([mfilename 'E:SampRateFault'],sprintf('Sampling rate fault is high: %e. Please check!',dblSampRateFault));
	end
	
	%% prepare pupil synchronization
	fprintf('Filtering pupil synchronization data [%s]\n',getTime);
	vecPupilSyncLum = sPupil.vecPupilSyncLum;
	vecPupilTime = sPupil.vecPupilTime;
	dblSampRatePupil = 1/median(diff(vecPupilTime));
	
	%filter to 0.1-30Hz
	vecWindow2 = [0.5 30]./(dblSampRatePupil./2);
	[fb,fa] = butter(2,vecWindow2,'bandpass');
	vecFiltSyncLum = filtfilt(fb,fa, double(vecPupilSyncLum));
	boolPupilSync = vecFiltSyncLum>(-std(vecFiltSyncLum)/2);
	
	%get on/off
	vecChangePupilSync = diff(boolPupilSync);
	vecPupilSyncOn = (find(vecChangePupilSync == 1)+1);
	vecPupilSyncOff = (find(vecChangePupilSync == -1)+1);
	
	%% load stimulus info
	%load logging file
	fprintf('Synchronizing multi-stream data...\n');
	dblLastStop = 0;
	sFiles = dir(fullfile(strPathStimLogs,['*_' strMouse '*' strThisRecIdx '_*.mat']));
	intLogs = numel(sFiles);
	if intLogs == 0
		error([mfilename ':NoLogsFound'],'No log files found');
	else
		fprintf('\b   Found %d log files [%s]\n',intLogs,getTime);
	end
	
	%% determine temporal order
	cellFiles = {sFiles(:).name};
	vecTimes = nan(1,intLogs);
	for intLogFile = 1:intLogs
		cellSplit = strsplit(cellFiles{intLogFile}(1:(end-4)),'_');
		vecTimes(intLogFile) = str2double(cat(2,cellSplit{end-2:end}));
	end
	[dummy,vecReorderStimFiles] = sort(vecTimes);
	
	%% run
	cellStim = cell(1,intLogs);
	for intLogFile = 1:intLogs
		%% calculate stimulus times
		fprintf('>Log file "%s" [%s]\n',sFiles(vecReorderStimFiles(intLogFile)).name,getTime)
		cellStim{intLogFile} = load(fullfile(strPathStimLogs,sFiles(vecReorderStimFiles(intLogFile)).name));
		strStimType = cellStim{intLogFile}.structEP.strFile;
		
		intThisNumTrials = numel(~isnan(cellStim{intLogFile}.structEP.ActOffSecs));
		if isfield(cellStim{intLogFile}.structEP,'ActOnNI') && ~all(isnan(cellStim{intLogFile}.structEP.ActOnNI))
			vecStimActOnNI = cellStim{intLogFile}.structEP.ActOnNI - intFirstSample/dblSampRateNI;
			vecStimActOffNI = cellStim{intLogFile}.structEP.ActOffNI - intFirstSample/dblSampRateNI;
		else
			%approximate timings
			vecStimOn = vecStimOnScreenPD/dblSampRateNI;
			vecStimOff = vecStimOffScreenPD/dblSampRateNI;
			%remove prior entries
			vecStimOn(vecStimOn < dblLastStop) = [];
			vecStimOff(vecStimOff < dblLastStop) = [];
			%ensure identical size
			if vecStimOff(1) < vecStimOn(1),vecStimOff(1) = [];end
			if numel(vecStimOn) > numel(vecStimOff),vecStimOn(end) = [];end
			%calc dur
			vecStimDur = vecStimOff - vecStimOn;
			
			%remove all durations shorter than single frame
			vecRemStims = vecStimDur <= cellStim{intLogFile}.structEP.dblStimFrameDur;
			vecStimDur(vecRemStims) = [];
			vecStimOn(vecRemStims) = [];
			vecStimOff(vecRemStims) = [];
			
			%get real but inaccurate timings
			vecStimActOnSecs = cellStim{intLogFile}.structEP.ActOnSecs - cellStim{intLogFile}.structEP.ActOnSecs(1);
			vecStimActOffSecs = cellStim{intLogFile}.structEP.ActOffSecs - cellStim{intLogFile}.structEP.ActOnSecs(1);
			
			%go through onsets to check which one aligns with timings
			vecSignalOnT = vecStimOnScreenPD/dblSampRateNI;
			intStims = numel(vecSignalOnT);
			vecError = nan(1,intStims);
			for intStartStim=1:intStims
				%select onsets
				vecUseSignalOnT = vecSignalOnT(intStartStim:end);
				
				%get ON times
				[vecStimOnTime,vecDiffOnT] = OT_refineT(vecStimActOnSecs,vecUseSignalOnT - vecUseSignalOnT(1),inf);
				vecError(intStartStim) = nansum(vecDiffOnT.^2);
			end
			[dblMin,intStartStim] = min(vecError);
			dblStartT = vecSignalOnT(intStartStim);
			
			%get probability
			vecSoftmin = softmax(-vecError);
			[vecP,vecI]=findmax(vecSoftmin,10);
			dblAlignmentCertainty = vecP(1)/sum(vecP);
			fprintf('Aligned onsets with %.3f%% certainty; start stim is at t=%.3fs\n',dblAlignmentCertainty*100,dblStartT);
			if (dblAlignmentCertainty < 0.9 || isnan(dblAlignmentCertainty)) && ~(intLogFile == 1 && intRunPrePro == 7) && ~(intLogFile == 2 && intRunPrePro == 10)
				error([mfilename 'E:CheckAlignment'],'Alignment certainty is under 90%%, please check manually');
			end
			%ensure same starting time
			vecStimActOnNI = vecStimActOnSecs + dblStartT;
			vecStimActOffNI = vecStimActOffSecs + dblStartT;
			
		end
		%remove missing stimuli
		vecRem = isnan(vecStimActOnNI) | isnan(vecStimActOffNI);
		dblLastStop = max(vecStimActOffNI);
		cellStim{intLogFile}.structEP = remStimAP(cellStim{intLogFile}.structEP,vecRem);
			
		%get ON times
		dblMaxErr = 0.1;
		vecPresStimOnT = vecStimActOnNI(~vecRem);
		vecSignalOnT = vecStimOnScreenPD/dblSampRateNI;
		[vecStimOnTime,vecDiffOnT] = OT_refineT(vecPresStimOnT,vecSignalOnT,inf);
		indReplace = abs(nanzscore(vecDiffOnT)) > 5;
		vecStimOnTime(indReplace) = vecStimActOnNI(indReplace) - median(vecDiffOnT);
		fprintf('Average timing error is %.3fs for stimulus onsets; %d violations, %d corrected\n',mean(abs(vecDiffOnT)),sum(abs(vecDiffOnT) > dblMaxErr),sum(indReplace));
		
		%get OFF times
		if contains(strStimType,'NaturalMovie') %set offsets to movie midpoint
			vecPresStimOffT = vecStimActOffNI(~vecRem) - median(diff(vecStimActOffNI(~vecRem)))/2;
		else
			vecPresStimOffT = vecStimActOffNI(~vecRem);
		end
		vecSignalOffT = vecStimOffScreenPD/dblSampRateNI;
		[vecStimOffTime,vecDiffOffT] = OT_refineT(vecPresStimOffT,vecSignalOffT,inf);
		indReplace = abs(nanzscore(vecDiffOffT)) > 5;
		vecStimOffTime(indReplace) = vecStimActOffNI(indReplace) - median(vecDiffOffT);
		fprintf('Average timing error is %.3fs for stimulus offsets; %d violations, %d corrected\n',mean(abs(vecDiffOffT)),sum(abs(vecDiffOffT) > dblMaxErr),sum(indReplace));
		
		% save to cell array
		cellStim{intLogFile}.structEP.vecStimOnTime = vecStimOnTime;
		cellStim{intLogFile}.structEP.vecStimOffTime = vecStimOffTime;
		cellStim{intLogFile}.structEP.ActOnNI = vecStimActOnNI;
		cellStim{intLogFile}.structEP.ActOffNI = vecStimActOffNI;
		cellStim{intLogFile}.structEP.SampRateNI = dblSampRateNI;
		
		%% align eye-tracking data
		if boolOnlyJson || intRunPrePro == 9 && intLogFile == 1,continue;end
		%get pupil on/offsets
		vecSignalOnT = vecPupilSyncOn(intLastPupilStop:end)/dblSampRatePupil;
		vecSignalOffT = vecPupilSyncOff(intLastPupilStop:end)/dblSampRatePupil;
		
		%build approximate onsets
		vecEyeStimOnT = vecStimOnTime - vecStimOnTime(1);
		vecEyeStimOffT = vecStimOffTime - vecStimOnTime(1);
		
		%first onset has 0.3s delay
		if contains(strStimType,'NaturalMovie')
			vecEyeStimOnT(2:end) = vecEyeStimOnT(2:end) - 0.3;
			vecEyeStimOffT = vecStimOffTime - 0.3;
		end
		
		%go through onsets to check which one aligns with timings
		intStims = numel(vecSignalOnT);
		vecError = nan(1,intStims);
		for intStartStim=1:intStims
			%select onsets
			vecUseSignalOnT = vecSignalOnT(intStartStim:end);
			
			%get ON times
			[vecPupilOnT,vecDiffPupilOnT] = OT_refineT(vecEyeStimOnT,vecUseSignalOnT - vecUseSignalOnT(1),inf);
			vecError(intStartStim) = nansum(vecDiffPupilOnT.^2);
		end
		[dblMin,intStartStim] = min(vecError);
		dblStartT = vecSignalOnT(intStartStim);
		
		%get probability
		vecSoftmin = softmax(-vecError);
		[vecP,vecI]=findmax(vecSoftmin,10);
		dblAlignmentCertainty = vecP(1)/sum(vecP);
		fprintf('Aligned pupil onsets with %.3f%% certainty; start stim is at t=%.3fs\n',dblAlignmentCertainty*100,dblStartT);
		if dblAlignmentCertainty < 0.9 || isnan(dblAlignmentCertainty)
			fprintf('\n << Alignment certainty is under 90%%, please check manually >>\n');
			[dblStartHiDefT,dblUserStartT] = askUserForSyncTimes(vecPupilSyncLum,vecPupilTime,intLogFile);
		
			%re-align
			[dblMin,intUserStartStim] = min(abs(vecSignalOnT-dblStartHiDefT));
			fprintf('My guess (%.3f%% confidence): %.3fs; your guess: %.3fs (I gave it %.3f%% probability)\n',dblAlignmentCertainty*100,dblStartT,dblStartHiDefT,(vecP(vecI==intUserStartStim)/sum(vecP))*100);
			dblStartT = dblStartHiDefT;
		end
		
		%ensure same starting time
		vecEyeStimActOn = vecEyeStimOnT(~vecRem) + dblStartT;
		vecEyeStimActOff = vecEyeStimOffT(~vecRem) + dblStartT;
		
		%get ON times
		dblMaxErr = 0.1;
		[vecPupilStimOnTime,vecDiffOnT] = OT_refineT(vecEyeStimActOn,vecSignalOnT,inf);
		indReplace = abs(nanzscore(vecDiffOnT)) > 5;
		vecPupilStimOnTime(indReplace) = vecEyeStimActOn(indReplace) - median(vecDiffOnT);
		fprintf('Average timing error is %.3fs for pupil stim onsets; %d violations, %d corrected\n',mean(abs(vecDiffOnT)),sum(abs(vecDiffOnT) > dblMaxErr),sum(indReplace));
		
		%get OFF times
		if contains(strStimType,'NaturalMovie') %set offsets to movie midpoint
			vecPupilStimOffTime = vecEyeStimActOn + median(diff(vecEyeStimActOn))/2;
		else
			dblMaxErr = 0.1;
			[vecPupilStimOffTime,vecDiffOffT] = OT_refineT(vecEyeStimActOff,vecSignalOffT,inf);
			indReplace = abs(nanzscore(vecDiffOffT)) > 5;
			vecPupilStimOffTime(indReplace) = vecEyeStimActOff(indReplace) - median(vecDiffOffT);
			fprintf('Average timing error is %.3fs for pupil stim offsets; %d violations, %d corrected\n',mean(abs(vecDiffOffT)),sum(abs(vecDiffOffT) > dblMaxErr),sum(indReplace));
		end
		intLastPupilStop = find((vecPupilSyncOn/dblSampRatePupil)>vecPupilStimOffTime(end),1);
		
		%assign stim on/off times
		vecPupilStimOnFrame = round(vecPupilStimOnTime * dblSampRatePupil);
		vecPupilStimOffFrame = round(vecPupilStimOffTime * dblSampRatePupil);
		cellStim{intLogFile}.structEP.vecPupilStimOnTime = vecPupilStimOnTime;
		cellStim{intLogFile}.structEP.vecPupilStimOffTime = vecPupilStimOffTime;
		cellStim{intLogFile}.structEP.vecPupilStimOnFrame = vecPupilStimOnFrame;
		cellStim{intLogFile}.structEP.vecPupilStimOffFrame = vecPupilStimOffFrame;
	end
	
	%% load clustered data into matlab using https://github.com/cortex-lab/spikes
	%load rez
	fprintf('Loading clustered spiking data at %s [%s]\n',strPathEphys,getTime);
	sLoad = load(fullfile(strPathEphys,'rez2.mat'));
	sRez = sLoad.rez;
	vecKilosortContamination = sRez.est_contam_rate;
	vecKilosortGood = sRez.good;
	
	% load some of the useful pieces of information from the kilosort and manual sorting results into a struct
	sSpikes = loadKSdir(strPathEphys);
	vecAllSpikeTimes = sSpikes.st;
	vecAllSpikeClust = sSpikes.clu;
	vecClusters = unique(vecAllSpikeClust);
	
	%get channel depth from pia
	sChanMap=load(strChanMapFile);
	vecChannelDepth = sChanMap.ycoords;
	vecChannelDepth = vecChannelDepth - max(vecChannelDepth);
	if dblInvertLeads,vecChannelDepth = vecChannelDepth(end:-1:1);end
	vecChannelDepth = vecChannelDepth + dblCh1DepthFromPia;
	
	%get cluster data
	fprintf('Assigning spikes to clusters... [%s]\n',getTime);
	[spikeAmps, vecAllSpikeDepth] = templatePositionsAmplitudes(sSpikes.temps, sSpikes.winv, sSpikes.ycoords, sSpikes.spikeTemplates, sSpikes.tempScalingAmps);
	vecAllSpikeDepth = dblCh1DepthFromPia - vecAllSpikeDepth;
	
	%remove nans
	for intStim=1:numel(cellStim)
		matStimOnOff = [cellStim{intStim}.structEP.vecStimOnTime;cellStim{intStim}.structEP.vecStimOffTime]';
		%remove nans
		vecRem = any(isnan(matStimOnOff),2);
		matStimOnOff(vecRem,:) = [];
		cellStim{intStim}.structEP = remStimAP(cellStim{intStim}.structEP,vecRem);
	end
	
	%% prepare spiking cell array
	intClustNum = numel(vecClusters);
	cellSpikes = cell(1,intClustNum);
	vecDepth = nan(1,intClustNum);
	for intCluster=1:intClustNum
		intClustIdx = vecClusters(intCluster);
		cellSpikes{intCluster} = vecAllSpikeTimes(vecAllSpikeClust==intClustIdx);
		vecDepth(intCluster) = mean(vecAllSpikeDepth(vecAllSpikeClust==intClustIdx));
	end
	if ~boolOnlyJson
	%% go through clusters
	sCluster = struct;
	parfor intCluster=1:intClustNum
		%get cluster idx
		intClustIdx = vecClusters(intCluster);
		vecSpikeTimes = cellSpikes{intCluster};
		sOut = getClusterQuality(vecSpikeTimes,0);
		
		%get responsiveness
		ZetaP = nan(1,numel(cellStim));
		MeanP = nan(1,numel(cellStim));
		for intStim=1:numel(cellStim)
			matStimOnOff = [cellStim{intStim}.structEP.vecStimOnTime;cellStim{intStim}.structEP.vecStimOffTime]';
			
			%get responsiveness
			[dblZETA,vecLatencies,sZETA] = getZeta(vecSpikeTimes,matStimOnOff,nanmedian(diff(cellStim{intStim}.structEP.vecStimOnTime)),50,0,0);
			if isempty(sZETA),continue;end
			ZetaP(intStim) = sZETA.dblP;
			MeanP(intStim) = sZETA.dblMeanP;
		end
		
		%assign to object
		sCluster(intCluster).Exp = strExperiment;
		sCluster(intCluster).Rec = strRecording;
		sCluster(intCluster).Area = [];
		sCluster(intCluster).MouseType = strMouseType;
		sCluster(intCluster).Mouse = strMouse;
		sCluster(intCluster).Date = getDate;
		sCluster(intCluster).Depth = vecDepth(intCluster);
		sCluster(intCluster).Cluster = intCluster;
		sCluster(intCluster).IdxClust = intClustIdx;
		sCluster(intCluster).SpikeTimes = vecSpikeTimes;
		sCluster(intCluster).NonStationarity = sOut.dblNonstationarityIndex;
		sCluster(intCluster).Violations1ms = sOut.dblViolIdx1ms;
		sCluster(intCluster).Violations2ms = sOut.dblViolIdx2ms;
		sCluster(intCluster).Contamination = vecKilosortContamination(intCluster);
		sCluster(intCluster).KilosortGood = vecKilosortGood(intCluster);
		sCluster(intCluster).ZetaP = ZetaP;
		sCluster(intCluster).MeanP = MeanP;
		
		%msg
		fprintf('Cell %d/%d, Z-p=%.3f,M-p=%.3f, Non-stat=%.3f, Viol=%.3f, Contam=%.3f [%s]\n',...
			intCluster,intClustNum,min(ZetaP),min(MeanP),sOut.dblNonstationarityIndex,sOut.dblViolIdx2ms,vecKilosortContamination(intCluster),getTime);
	end
	
	%% load LFP data
	%{
	strFileLFP = strcat(strRecording,'_t0.imec0.lf.bin');
	fprintf('Filtering LFP data at %s [%s]\n',strFileLFP,getTime);
	sMetaLFP = DP_ReadMeta(strFileLFP, strPathEphys);
	matLFP = DP_ReadBin(0, inf, sMetaLFP, strFileLFP, strPathEphys, 'single');
	
	dblSampRateLFP = DP_SampRate(sMetaLFP);
	vecTimestampsLFP = (1:size(matLFP,2))/dblSampRateLFP;
	
	%filter each channel
	for intCh=1:size(matLFP,1)
		%get data
		vecFiltered = double(matLFP(intCh,:));
		
		%filter 50Hz
		vecWindow = [49.95 50.05]./(dblSampRateLFP./2);
		[fb,fa] = butter(2,vecWindow,'stop');
		vecFiltered = filtfilt(fb,fa,vecFiltered);
		
		%filter to 0.01-300Hz
		vecWindow2 = [0.01 300]./(dblSampRateLFP./2);
		[fb,fa] = butter(2,vecWindow2,'bandpass');
		vecFiltered = filtfilt(fb,fa,vecFiltered);
		matLFP(intCh,:) = cast(vecFiltered,'like',matLFP);
		
		%calc power
		%[vecFreq,vecPower] = getPowerSpectrum(vecFiltered,dblSampRateLFP,2);
		%loglog(vecFreq(5:end-4),conv(vecPower,normpdf(-4:4,0,2),'valid'));
	end
	%}
	end
	%% combine all data and save to post-processing data file
	%build Acquipix post-processing structure
	fprintf('Combining data and saving to disk... [%s]\n',getTime);
	sAP = struct;
	strFileOut = strcat(strExperiment,'_',strMouse,'_',strRecIdx,'_AP');
	strFileAP = strcat(strPathDataTarget,strFileOut,'.mat');
	strSecondPathAP = 'D:\Data\Processed\Neuropixels\';
	strFileAP2 = strcat(strSecondPathAP,strFileOut,'.mat');
	%save LFP separately because of large size
	%sAP_LFP = struct;
	%strFileOutLFP = strcat(strFileOut,'_LFP');
	%strFileLFP = strcat(strPathDataTarget,strFileOutLFP,'.mat');
	
	%LFP
	%sAP_LFP.vecTimestampsLFP = vecTimestampsLFP;
	%sAP_LFP.matLFP = matLFP;
	%sAP_LFP.sMetaLFP = sMetaLFP;
	
	%stimulation & eye-tracking timings
	sAP.cellStim = cellStim;
	sAP.sPupil = sPupil;
	
	%probe data
	sAP.vecChannelDepth = vecChannelDepth;
	if ~boolOnlyJson
	%clusters & spikes
	sAP.sCluster = sCluster;
	
	%NI meta file
	sAP.sMetaNI = sMetaNI;
	%sAP.strFileLFP = strFileLFP;
	
	%save AP
	fprintf('Saving AP data to %s [%s]\n',strFileAP,getTime);
	save(strFileAP,'sAP');
	fprintf('Saving AP data to %s [%s]\n',strFileAP2,getTime);
	save(strFileAP2,'sAP');
	
	%save LFP
	%fprintf('Saving LFP data to %s [%s]\n',strFileLFP,getTime);
	%save(strFileLFP,'sAP_LFP','-v7.3');
	%fprintf('Done\n');!
	end
	
	%% generate json file for library
	%split recording name & define data
	cellData = strsplit(strRecording,'_');
	strRecDate = cellData{1};
	if ~exist('strFileLFP','var'),strFileLFP='';end
	
	%required fields
	sJson = struct;
	sJson.date = strRecDate;
	sJson.version = '1.0';
	sJson.project = 'MontijnNPX2020';
	sJson.dataset = 'Neuropixels data';
	sJson.subject = strMouse;
	sJson.investigator = 'Jorrit_Montijn';
	sJson.setup = 'Neuropixels';
	sJson.stimulus = 'VisStimAcquipix';
	sJson.condition = 'none';
	sJson.id = strjoin({strRecIdx,strMouse,strExperiment,strThisRecIdx},'_');
	
	%additional fields
	sJson.experiment = strExperiment;
	sJson.recording = strRecording;
	sJson.recidx = strRecIdx;
	sJson.mousetype = strMouseType;
	sJson.nstims = num2str(numel(cellStim));
	sJson.stims = strjoin(cellfun(@(x) x.structEP.strFile,cellStim,'uniformoutput',false),';');
	sJson.trials = strjoin(cellfun(@(x) num2str(numel(x.structEP.vecStimOnTime)),cellStim,'uniformoutput',false),';');
	sJson.nclust = numel(vecKilosortGood);
	sJson.ngood = sum(vecKilosortGood);
	
	%check meta data
	cellFields = fieldnames(sMetaNI);
	intMetaField = find(contains(cellFields,'recording'));
	if numel(intMetaField) == 1
		sJson.recording = strjoin({sMetaNI.(cellFields{intMetaField}),cellFields{intMetaField}},'_');
	else
		sJson.recording = '';
		warning([mfilename 'W:NoMetaField'],'Meta field not found in NI header file');
	end
	
	%file locations
	sJson.file_ap = strFileAP;
	sJson.file_ap2 = strFileAP2;
	sJson.file_lfp = strFileLFP;
	sJson.file_ni = sMetaNI.fileName;
	
	%save json file
	strJsonData = jsonencode(sJson);
	strJsonFileOut = strcat(strExperiment,'_',strMouse,'_',strRecIdx,'.json');
	strJsonTarget = fullfile(strPathDataTarget,strJsonFileOut);
	fprintf('Saving json metadata to %s [%s]\n',strJsonTarget,getTime);
	save(strJsonTarget,'strJsonData');
end