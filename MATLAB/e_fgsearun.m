function [s]=e_fgsearun(T,rmribo,dbfile)
% Run fast GSEA (fGSEA) analysis in R
if nargin<2, rmribo=true; end
if nargin<3, dbfile='all'; end   % bp mf

if isempty(FindRpath)
   error('Rscript.exe is not found.');
end

oldpth=pwd;
pw1=fileparts(which(mfilename));
pth=fullfile(pw1,'thirdparty','fgsea');
cd(pth);
fprintf('CURRENTWDIR = "%s"\n',pth);

if exist('output.txt','file'), delete('output.txt'); end

if ~matches('genelist',T.Properties.VariableNames) && ...
        matches('Var1',T.Properties.VariableNames)
    if length(T.Properties.VariableNames)==5
        T.Properties.VariableNames={'genelist','drdist','FC','pValues','pAdjusted'};
        disp('Table variable names added.')
    end
end

[~,idx]=unique(upper(string(T.genelist)),'stable');
if size(T,1)-length(idx)>0
    disp('Duplicate genes removed.');
end
T=T(idx,:);

T.genelist=upper(string(T.genelist));


if rmribo
    [gribo]=pkg.i_get_ribosomalgenes;  % a scGEAToolbox function
    i=~ismember(T.genelist,gribo);
    T=T(i,:);
end
writetable(T,'input.txt');
switch lower(dbfile)
    case 'all'
        RunRcode('script.R');
    case 'bp'
        RunRcode('scrpt_bp.R');
    case 'mf'
        RunRcode('scrpt_mf.R');
end
pause(1);
if exist('output.txt','file')
    s=readtable('output.txt',"Delimiter",',');
else
    s=[];
end
if exist('input.txt','file'), delete('input.txt'); end
if exist('output.txt','file'), delete('output.txt'); end
cd(oldpth);
