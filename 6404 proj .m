clear all;
%% data input
pbc=xlsread ('./pbc_nomissing');

% lived days
days = pbc(:,2);

idx_censor = 1-pbc(:,3); %1 for censored, 0 for observed death

% treatment 
treatment = pbc(:,4);  %1 - D-Penicillamine, 2 - Placebo

% patients' basic 'attributes'
age = pbc(:,5); %age in years
gender = pbc(:,6);   %0 male, 1 female

% symptoms
ascites= pbc(:,7);   %0 no, 1 yes 
hepatomegaly=pbc(:,8); %0 no, 1 yes 
spiders = pbc(:,9);   %0 no, 1 yes
edema = pbc(:,10); %0 no, 0.5 present/no terapy, 1 present/terapy given

% measurements
bilirubin = pbc(:,11); %bilirubin [mg/dl]  
cholesterol  = pbc(:,12);   %cholesterol [mg/dl]  
albumin = pbc(:,13); %albumin [gm/dl]  
ucopper =pbc(:,14); %urine copper [mg/day]  
aphosp =pbc(:,15);  %alcaline phosphatase [U/liter] 
sgot = pbc(:,16); %SGOT [U/ml]
trig =pbc(:,17); %triglycerides [mg/dl]  
platelet = pbc(:,18);     %# platelet count [#/mm^3]/1000  
prothro = pbc(:,19); %prothrombin time [sec]  ????
hystage = pbc(:,20); %hystologic stage [1,2,3,4]

% correlation plot
R=corrcoef(pbc);
abs(R)>0.5; % found strong correlation between Z7 and Z10, i.e. there exists 
            % strong correlation between edema and albumin

% Kruskal-Wallis test to compare three or more unmatched groups
[pval, H, aver1 ] = kruskalwallistest(days, edema) % p value is 9.4721e-10, which means there is significant difference 
                                                   % between lived times under different edema levels
% Kruskal-Wallis test to compare age categories and gender categories
age1_index = age>50; % 154 patients
[pval1, H, aver1 ] = kruskalwallistest(days, age<50) 
[pval2, H, aver1 ] = kruskalwallistest(days, gender)
% Kruskal-Wallis test to compare the effectiveness of treatment D-penicillamine
[table0] = kwpairwise(days, treatment)
[table1] = kwpairwise(ascites, treatment)
[table2] = kwpairwise(hepatomegaly, treatment)
[table3] = kwpairwise(spiders, treatment)
[table4]=kwpairwise(edema, treatment)
% CI of days, ascites, edema contains 0, so there is no significant
% difference between treatment D-penicillamine and placebo for these
% features; however, CI of hepatomegaly and spiders are both negative, so
% treatment has a negative effect on these two symptoms. 
%% develop risk function model using kernel method 
% select risk features: age, gender, four
% symptoms-ascites,hepatomegaly,spiders, edema; measurement features like
% bilirubin,cholesterol, albumin, urine copper, sgot, prothro, hystage, 

X = [ age gender ascites hepatomegaly spiders edema bilirubin cholesterol albumin ucopper sgot prothro hystage]

[B,LOGL,H,STATS] = coxphfit(X,days,'censoring',idx_censor,'baseline',0);
B % model coefficients
STATS.p % age, edema, bilirubin, albumin, urine copper, sgot, prothro, hystage are significant
stairs(H(:,1),exp(-H(:,2)))
xx = linspace(0,100);
% line(xx,1-wblcdf(xx,50*exp(-0.5*mean(X)),B),'color','r')
title(sprintf('Baseline survivor function for X=%g',mean(X)))

% data survival curve based on lived days
[table]=ple(days,idx_censor)
title(sprintf('Survival Curve for PBC data'))
