function [difference sigcrit]=wcomposite(x,y,alpha0)
%
% Updated by Zhiang Xie, 13 Jan 2019
%
% Function for Weighted Composite Analysis (WCA) with Monte Carlo two-tails test
% 
% Ex. [WCA significance] = wcomposite(index,field,alpha0)
% Input: 
% where [index] represents the 1d index to tell phase of event, 
% [field] represents physical field, which must be 3d variable and time is the rightmost dimension
% [alpha0] is significant criterion, e.g. 0.95 for 95% siginificant test, 
% 200 samples are defaultly used in Monte Carlo test
% Output:
% where WCA is 3d variables, the first two dimensions same as input field 
% [WCA(:,:,1)] represents the result in positive phase, [WCA(:,:,2)] for negative and [WCA(:,:,3)] for difference
% [significance] shares the same dimension with WCA, representing the significant test result, 
% 1 for significant and 0 for insignificant
%
% 中文注释：
% 计算加权合成分析的函数，采用双侧蒙特卡洛检验
% 函数形式 [WCA significance]=wcomposite(index,field,alpha0)
% 其中index为一维指数，field为加权合成分析的物理量场，必须为三维变量，第三维为时间维，
% alpha0是统计检验标准，如0.95表示95%统计检验,默认采用双侧检验，蒙特卡洛检验采用200个样本
% 输出量WCA为三维变量，前两维与输入的field相同，第三维为不同异常结果，正异常结果为WCA(:,:,1),负异常为WCA(:,:,2)，合成差为WCA(:,:,3)
% significance维数与WCA相同，为显著检验结果,为1即该格点通过检验，为0则该格点未通过检验
%

sizlen=size(x);
if sizlen(1)==1
    x=x';
    sizlen=sizlen(2);
else
    sizlen=sizlen(1);
end

% Two-tail test, notate following section for one-tail test
%-----------------------
alpha0=(1+alpha0)/2;
%-----------------------

sizy=size(y);
siznum=3;

% Composite sumation
x_anomal=x-mean(x);
y_mean=mean(y,siznum);
y_anomal=y-repmat(y_mean,[ones(1,siznum-1) sizy(siznum)]);
p=find(x_anomal>0);
n=find(x_anomal<0);

% Difference last dimension：1.positive part; 2.negative part; 3. differnece
difference=nan(sizy(1),sizy(2),3);
for k1=1:sizy(1)
    for k2=1:sizy(2)
      difference(k1,k2,1)=sum(x_anomal(p).*squeeze(y_anomal(k1,k2,p)))/sum(abs(x_anomal(p)))+y_mean(k1,k2);
      difference(k1,k2,2)=-sum(x_anomal(n).*squeeze(y_anomal(k1,k2,n)))/sum(abs(x_anomal(n)))+y_mean(k1,k2);
    end
end
difference(:,:,3)=difference(:,:,1)-difference(:,:,2);

% Significant test
N=200; % ensample number 
diff_test=nan(sizy(1),sizy(2),N,3);
% WCA for every sample
for k=1:N
  order=randperm(sizlen);
  x_test=x(order);
  x_test=x_test-mean(x_test);
  p=find(x_test>0);
  n=find(x_test<0);
    for k1=1:sizy(1)
        for k2=1:sizy(2)
         diff_test(k1,k2,k,1)=sum(x_test(p).*squeeze(y_anomal(k1,k2,p)))/sum(abs(x_test(p)))+y_mean(k1,k2);
         diff_test(k1,k2,k,2)=-sum(x_test(n).*squeeze(y_anomal(k1,k2,n)))/sum(abs(x_test(n)))+y_mean(k1,k2);
        end
    end
end
% The significant interval
diff_test(:,:,:,3)=diff_test(:,:,:,1)-diff_test(:,:,:,2);
sigcrit=zeros(sizy(1),sizy(2),3);
for k=1:3
    for k1=1:sizy(1)
        for k2=1:sizy(2)
         diff_test_sig=sort(diff_test(k1,k2,:,k),3);
         sigcrit1=diff_test_sig(1,1,floor(N*alpha0)+1); % upper bound
         sigcrit2=diff_test_sig(1,1,floor(N*(1-alpha0))-1); % bottom bound
         if difference(k1,k2,k)>sigcrit1
             sigcrit(k1,k2,k)=1;
         elseif difference(k1,k2,k)<sigcrit2
             sigcrit(k1,k2,k)=1;
        end
    end
end

end
